# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "enqueue"
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ryan Scott Lewis"]
  s.date = "2012-12-13"
  s.description = "Interface with message queues with ease."
  s.email = "ryan@rynet.us"
  s.files = ["Gemfile", "Gemfile.lock", "LICENSE", "README.md", "Rakefile", "VERSION", "enqueue.gemspec", "lib/enqueue.rb"]
  s.homepage = "http://github.com/RyanScottLewis/enqueue"
  s.post_install_message = "Enqueue is not yet finished, check back with this gem has a MINOR version!"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Enqueue is an interface to message queues for easy parallel processing."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<version>, ["~> 1.0"])
      s.add_development_dependency(%q<at>, ["~> 0.1"])
      s.add_development_dependency(%q<rake>, ["~> 10.0"])
      s.add_development_dependency(%q<guard-rspec>, ["~> 2.1"])
      s.add_development_dependency(%q<guard-yard>, ["~> 2.0"])
      s.add_development_dependency(%q<rb-fsevent>, ["~> 0.9"])
      s.add_development_dependency(%q<fuubar>, ["~> 1.1"])
      s.add_development_dependency(%q<redcarpet>, ["~> 2.2.2"])
      s.add_development_dependency(%q<github-markup>, ["~> 0.7"])
    else
      s.add_dependency(%q<version>, ["~> 1.0"])
      s.add_dependency(%q<at>, ["~> 0.1"])
      s.add_dependency(%q<rake>, ["~> 10.0"])
      s.add_dependency(%q<guard-rspec>, ["~> 2.1"])
      s.add_dependency(%q<guard-yard>, ["~> 2.0"])
      s.add_dependency(%q<rb-fsevent>, ["~> 0.9"])
      s.add_dependency(%q<fuubar>, ["~> 1.1"])
      s.add_dependency(%q<redcarpet>, ["~> 2.2.2"])
      s.add_dependency(%q<github-markup>, ["~> 0.7"])
    end
  else
    s.add_dependency(%q<version>, ["~> 1.0"])
    s.add_dependency(%q<at>, ["~> 0.1"])
    s.add_dependency(%q<rake>, ["~> 10.0"])
    s.add_dependency(%q<guard-rspec>, ["~> 2.1"])
    s.add_dependency(%q<guard-yard>, ["~> 2.0"])
    s.add_dependency(%q<rb-fsevent>, ["~> 0.9"])
    s.add_dependency(%q<fuubar>, ["~> 1.1"])
    s.add_dependency(%q<redcarpet>, ["~> 2.2.2"])
    s.add_dependency(%q<github-markup>, ["~> 0.7"])
  end
end
