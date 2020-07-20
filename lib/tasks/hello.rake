desc "Say hello"
task :hello, [:name] => [:environment] do |t, args|
  puts "Hello #{args[:name]} 👋"
end
