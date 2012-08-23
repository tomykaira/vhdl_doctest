# A sample Guardfile
# More info at https://github.com/guard/guard#readme

require 'guard-notifier-git_auto_commit'

guard 'rspec', :version => 2 do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/vhdl_doctest/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

notification :git_auto_commit
notification :notifysend
