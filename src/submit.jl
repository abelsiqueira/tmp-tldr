export submit

function submit()
  V = Base.active_repl.mistate.current_mode.hist.history
  tmp_file, io = mktemp()
  println(io, """
{
  "command": "$(V[end-1])"
  "description": "[FILL]",
  "kind": "[snippet or header]",
  "package": "[FILL]",
  "tags": ["like", "this"]
}

# To abort, write #ABORT or delete everything
# Lines starting with # will be ignored.
# If submitting a new package leave "command" empty and use "header" kind.
# Otherwise, use kind "snippet".
  """)
  close(io)

  # Manually edit the result
  # TODO: Allow other editors
  tmp_editor = ENV["JULIA_EDITOR"]
  ENV["JULIA_EDITOR"] = "nano"
  edit(tmp_file)
  ENV["JULIA_EDITOR"] = tmp_editor

  # Delete comment lines and check for #ABORT
  lines = readlines(tmp_file)
  if any(match.(r"^\s*#\s*ABORT", lines) .!== nothing)
    @warn "Aborting due to #ABORT found"
    return
  end
  I = findall(match.(r"^\s*#", lines) .== nothing)
  lines = join(lines[I])
  myauth = GitHub.authenticate(ENV["GITHUB_AUTH"])
  msg = Dict(
    "body" => lines
  )
  GitHub.create_comment("abelsiqueira/tmp-tldr", 1, :issue, auth=myauth, params=msg)
end