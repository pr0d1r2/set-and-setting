{
  callerWorkflow,
  reusableWorkflow,
}:
let
  lines = path: builtins.filter builtins.isString (builtins.split "\n" (builtins.readFile path));

  jobNames =
    {
      path,
      reusableCallersOnly ? false,
    }:
    let
      keepCurrent =
        state:
        if state.current != null && (!reusableCallersOnly || state.currentUses) then
          state.names ++ [ state.current ]
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
              }
            else if state.inJobs && state.current != null && uses then
              state // { currentUses = true; }
            else if state.inJobs && topLevel then
              state
              // {
                inJobs = false;
                names = keepCurrent state;
                current = null;
              }
            else
              state
          )
          {
            inJobs = false;
            names = [ ];
            current = null;
            currentUses = false;
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
