{
  callerWorkflow,
  reusableWorkflow,
}:
let
  lines = path: builtins.filter builtins.isString (builtins.split "\n" (builtins.readFile path));

  # A required status context is a NAME. GitHub names a matrix job's contexts
  # `job (v)` -- or `job (v1, v2)` for several matrix keys, in the order the keys
  # are declared -- and NOTHING reports the bare `job` any more. So a workflow
  # that grows a matrix silently renames every context branch protection
  # requires, and a required context nobody reports never fails: it stays
  # PENDING forever and the PR can never merge. That is why this parser learns
  # about matrices BEFORE any workflow here has one -- with the current
  # non-matrix workflows the derived set is unchanged, which is the only moment
  # the change is provably safe (#421).
  trim =
    s:
    let
      m = builtins.match "^[[:space:]]*(.*[^[:space:]])[[:space:]]*$" s;
    in
    if m == null then "" else builtins.head m;
  unquote =
    s:
    let
      m = builtins.match "^(\"(.*)\"|'(.*)'|(.*))$" s;
      pick = builtins.filter (x: x != null) (builtins.tail m);
    in
    if pick == [ ] then s else builtins.head pick;
  value = s: unquote (trim s);

  # The matrix of ONE job, read from the lines that belong to it.
  # `include` / `exclude` change the generated set in ways this cannot see, so
  # they THROW rather than produce a name that is quietly wrong -- the failure
  # mode being avoided is precisely a plausible wrong name.
  matrixOf =
    jobName: body:
    let
      parsed =
        builtins.foldl'
          (
            state: line:
            let
              strategy = builtins.match "^    strategy:[[:space:]]*$" line != null;
              matrix = builtins.match "^      matrix:[[:space:]]*$" line != null;
              flow = builtins.match "^        ([A-Za-z0-9_-]+):[[:space:]]*[[](.*)[]][[:space:]]*$" line;
              openKey = builtins.match "^        ([A-Za-z0-9_-]+):[[:space:]]*$" line;
              item = builtins.match "^          -[[:space:]]+(.*)$" line;
              # A job's own body is indented 4; `strategy:` sits there and `matrix:`
              # under it. So the block ENDS at the next line indented 4 or less --
              # `fail-fast:` at 6 is INSIDE strategy and must not close it.
              leaves = builtins.match "^ {0,4}[^[:space:]].*$" line != null;
            in
            if strategy then
              state // { inStrategy = true; }
            else if state.inStrategy && matrix then
              state // { inMatrix = true; }
            else if state.inMatrix && flow != null then
              let
                key = builtins.head flow;
                vs = map value (builtins.filter builtins.isString (builtins.split "," (builtins.elemAt flow 1)));
              in
              state
              // {
                keys = state.keys ++ [
                  {
                    name = key;
                    values = builtins.filter (v: v != "") vs;
                  }
                ];
                open = null;
              }
            else if state.inMatrix && openKey != null then
              state
              // {
                keys = state.keys ++ [
                  {
                    name = builtins.head openKey;
                    values = [ ];
                  }
                ];
                open = builtins.head openKey;
              }
            else if state.inMatrix && state.open != null && item != null then
              let
                last = builtins.elemAt state.keys (builtins.length state.keys - 1);
                init = builtins.genList (i: builtins.elemAt state.keys i) (builtins.length state.keys - 1);
              in
              state
              // {
                keys = init ++ [ (last // { values = last.values ++ [ (value (builtins.head item)) ]; }) ];
              }
            else if leaves then
              state
              // {
                inStrategy = false;
                inMatrix = false;
                open = null;
              }
            else
              state
          )
          {
            inStrategy = false;
            inMatrix = false;
            keys = [ ];
            open = null;
          }
          body;
      named = builtins.filter (k: k.name != "include" && k.name != "exclude") parsed.keys;
      excluded = builtins.length parsed.keys != builtins.length named;
      empty = builtins.filter (k: k.values == [ ]) named;
    in
    if excluded then
      throw "job ${jobName}: matrix include/exclude is not supported -- the generated context names cannot be derived from the matrix keys alone"
    else if empty != [ ] then
      throw "job ${jobName}: matrix key ${(builtins.head empty).name} has no values this parser can read"
    else
      named;

  # `job` with no matrix, `job (a)` / `job (a, b)` with one -- the cartesian
  # product in DECLARATION order, which is the order GitHub prints.
  expand =
    jobName: keys:
    if keys == [ ] then
      [ jobName ]
    else
      let
        combos = builtins.foldl' (
          acc: key: builtins.concatMap (prefix: map (v: prefix ++ [ v ]) key.values) acc
        ) [ [ ] ] keys;
      in
      map (combo: "${jobName} (${builtins.concatStringsSep ", " combo})") combos;

  jobNames =
    {
      path,
      reusableCallersOnly ? false,
    }:
    let
      keepCurrent =
        state:
        if state.current != null && (!reusableCallersOnly || state.currentUses) then
          state.names ++ expand state.current (matrixOf state.current state.body)
        else
          state.names;
      parsed =
        builtins.foldl'
          (
            state: line:
            let
              job = builtins.match "^  ([A-Za-z0-9_-]+):[[:space:]]*(#.*)?$" line;
              uses = builtins.match "^    uses:[[:space:]]+.*$" line != null;
              topLevel = builtins.match "^[^[:space:]][^:]*:.*$" line != null;
            in
            if line == "jobs:" then
              state // { inJobs = true; }
            else if state.inJobs && job != null then
              state
              // {
                names = keepCurrent state;
                current = builtins.head job;
                currentUses = false;
                body = [ ];
              }
            else if state.inJobs && state.current != null && uses then
              state
              // {
                currentUses = true;
                body = state.body ++ [ line ];
              }
            else if state.inJobs && topLevel then
              state
              // {
                inJobs = false;
                names = keepCurrent state;
                current = null;
                body = [ ];
              }
            else if state.inJobs && state.current != null then
              state // { body = state.body ++ [ line ]; }
            else
              state
          )
          {
            inJobs = false;
            names = [ ];
            current = null;
            currentUses = false;
            body = [ ];
          }
          (lines path);
      names = keepCurrent parsed;
    in
    if names == [ ] then throw "workflow ${toString path} has no top-level jobs" else names;

  callerJobs = jobNames {
    path = callerWorkflow;
    reusableCallersOnly = true;
  };
  reusableJobs = jobNames { path = reusableWorkflow; };
in
builtins.concatMap (
  callerJob: map (reusableJob: "${callerJob} / ${reusableJob}") reusableJobs
) callerJobs
