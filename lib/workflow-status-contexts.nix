{
  callerWorkflow,
  reusableWorkflow,
}:
let
  lines = path: builtins.filter builtins.isString (builtins.split "\n" (builtins.readFile path));

  jobNames =
    path:
    let
      parsed =
        builtins.foldl'
          (
            state: line:
            let
              job = builtins.match "^  ([A-Za-z0-9_-]+):[[:space:]]*(#.*)?$" line;
              topLevel = builtins.match "^[^[:space:]][^:]*:.*$" line != null;
            in
            if line == "jobs:" then
              state // { inJobs = true; }
            else if state.inJobs && job != null then
              state // { names = state.names ++ [ (builtins.head job) ]; }
            else if state.inJobs && topLevel then
              state // { inJobs = false; }
            else
              state
          )
          {
            inJobs = false;
            names = [ ];
          }
          (lines path);
    in
    if parsed.names == [ ] then
      throw "workflow ${toString path} has no top-level jobs"
    else
      parsed.names;

  callerJobs = jobNames callerWorkflow;
  reusableJobs = jobNames reusableWorkflow;
in
builtins.concatMap (
  callerJob: map (reusableJob: "${callerJob} / ${reusableJob}") reusableJobs
) callerJobs
