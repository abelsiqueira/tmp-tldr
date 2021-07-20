using GitHub, Jet, JSON

cmts = GitHub.comments("abelsiqueira/tmp-tldr", 1, :issue)[1]
cmt = cmts[end]
D = JSON.parse(cmt.body)
Jet.new_entry(D["package"], D["kind"], D["command"], D["description"], D["tags"])
cimsg = ":robot: New entry: "
if D["package"] != ""
  cimsg *= D["package"] * " - "
end
cimsg *= D["description"]
println("::set-output name=cimsg::$cimsg")