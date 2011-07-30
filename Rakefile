#! /usr/bin/env rake
$LOAD_PATH.unshift('lib')

require 'rubygems'
require 'rake/gempackagetask'
require 'ruwiki'
require 'ruwiki/utils'
require 'ruwiki/utils/manager'
require 'zlib'

DISTDIR = "ruwiki-#{Ruwiki::VERSION}"
TARDIST = "../#{DISTDIR}.tar.gz"

DATE_RE = %r<(\d{4})[./-]?(\d{2})[./-]?(\d{2})(?:[\sT]?(\d{2})[:.]?(\d{2})[:.]?(\d{2})?)?>

if ENV['RELEASE_DATE']
  year, month, day, hour, minute, second = DATE_RE.match(ENV['RELEASE_DATE']).captures
  year ||= 0
  month ||= 0
  day ||= 0
  hour ||= 0
  minute ||= 0
  second ||= 0
  ReleaseDate = Time.mktime(year, month, day, hour, minute, second)
else
  ReleaseDate = nil
end

desc "Run Ruwiki unit tests."
task :test do |t|
  require 'test/unit/testsuite'
  require 'test/unit/ui/console/testrunner'

  runner = Test::Unit::UI::Console::TestRunner

  $LOAD_PATH.unshift('tests')
  $stderr.puts "Checking for test cases:" if t.verbose
  Dir['tests/tc_*.rb'].each do |testcase|
    $stderr.puts "\t#{testcase}" if t.verbose
    load testcase
  end

  suite = Test::Unit::TestSuite.new("Ruwiki Tests")

  ObjectSpace.each_object(Class) do |testcase|
    suite << testcase.suite if testcase < Test::Unit::TestCase
  end

  runner.run(suite)
end

task :clean_data do
  Dir["data/**/*"].each do |file|
    FileUtils.rm_f(file) if file =~ /(?:rdiff|lock|~)$/
  end
end

desc "Build the default Ruwiki deployment package."
task :package_data => [ :clean_data ] do
  Ruwiki::Utils::Manager.package(".", ".", nil, false)
end

task :make_readonly do
  data = nil
  Dir["data/**/*.ruwiki"].each do |file|
    File.open(file, "rb") { |f| data = f.read }
    FileUtils.cp(file, "#{file}.orig")
    if data =~ %r{properties!editable:}o
      data.gsub!(%r{^properties!editable:[ \t].*?$}, "properties!editable:\tfalse")
    else
      data << "properties!editable:\tfalse\n"
    end
    File.open(file, "wb") { |out| out.write(data) }
  end
end

task :clean_readonly do
  Dir["data/**/*.ruwiki"].each do |file|
    orig = "#{file}.orig"
    FileUtils.mv(orig, file) if File.exists?(orig)
  end
end

spec = Gem::Specification.new do |s|
  s.name      = %q(ruwiki)
  s.version   = Ruwiki::VERSION
  s.summary   = %q{A simple, extensible, and fast Wiki-clone.}

  s.add_dependency('diff-lcs', '~> 1.1.2')
  s.add_dependency('archive-tar-minitar', '~> 0.5.1')

  s.has_rdoc          = true
  s.rdoc_options      = ["--title", "Ruwiki - An Extensible Wiki", "--main", "Readme.tarfile", "--line-numbers"]
  s.extra_rdoc_files  = %w(Readme.tarfile Readme.rubygems)

  s.bindir        = 'bin'
  s.executables   = Dir['bin/**/*'].delete_if do |item|
    item =~ %r{(?:\bCVS\b|\.svn\b|[Rr]akefile|install.rb$|~$|gem(?:spec)?$)}
  end.map { |item| item.gsub(%r{^bin/}, "") }
  s.autorequire   = %q{ruwiki}
  s.require_paths = %w{lib}

  s.test_files    = %w{tests/testall.rb}

  files = Dir["**/*"].delete_if do |item|
    item =~ %r{\bCVS\b |
               \.svn\b |
               \.bak$  |
               [Rr]akefile |
               install\.rb$ |
               ~$ |
               gem(spec)?$ |
               lib/archive |
               lib/diff |
               \.ruwiki\.orig$}x
  end
  files << "ruwiki.pkg"
  s.files = files

  s.author            = %q{Austin Ziegler and Alan Chen}
  s.email             = %q{ruwiki-discuss@rubyforge.org}
  s.rubyforge_project = %q(ruwiki)
  s.homepage          = %q{http://ruwiki.rubyforge.org/}

  description   = []
  File.open("Readme.rubygems") do |file|
    file.each do |line|
      line.chomp!
      break if line.empty?
      description << "#{line.gsub(/\[\d\]/, '')}"
    end
  end
  s.description = description[2..-1].join(" ")
end
desc "Build the RubyGem for Ruwiki."
task :gem => [ :test ]
task :gem => [ :update_version ]
task :gem => [ :package_data ]
task :gem => [ :make_readonly ]
Rake::GemPackageTask.new(spec) do |g|
  g.need_tar    = false
  g.need_zip    = false
  g.package_dir = ".."
end

VERSION_STRING_RE = %r{\\?%RV#%}

desc "Update the version of Ruwiki to #{Ruwiki::VERSION} in documentation files."
task :update_version do
  FileList["data/**/*.ruwiki", "Readme*"].to_a.each do |file|
    data = File.read(file)
    data.gsub!(VERSION_STRING_RE) do |match|
      if match[0] == '\\'
        match
      else
        Ruwiki::VERSION
      end
    end
    File.open(file, "wb") { |f| f.write(data) }
  end
end

desc "Build a Ruwiki .tar.gz distribution."
task :tar => [ TARDIST ]
file TARDIST => [ :test, :update_version ] do |t|
  current = File.basename(Dir.pwd)
  Dir.chdir("..") do
    begin
      files = Dir["#{current}/**/*"].select { |dd| dd !~ %r{(?:/CVS/?|~$)} }
      files.delete_if { |dd| dd =~ %r{Rakefile} }
      files.map! do |dd|
        mtime = ReleaseDate || File.stat(dd).mtime
        ddnew = dd.gsub(/^#{current}/, DISTDIR)
        if File.directory?(dd)
          { :name => ddnew, :mode => 0755, :dir => true, :mtime => mtime }
        else
          if dd =~ %r{bin/}
            mode = 0755
          else
            mode = 0644
          end
          data = File.read(dd)
          { :name => ddnew, :mode => mode, :data => data, :size => data.size,
            :mtime => mtime }
        end
      end

      ff = File.open(t.name.gsub(%r{^\.\./}o, ''), "wb")
      gz = Zlib::GzipWriter.new(ff)
      tw = Archive::Tar::Minitar::Writer.new(gz)

      files.each do |entry|
        if entry[:dir]
          tw.mkdir(entry[:name], entry)
        else
          tw.add_file_simple(entry[:name], entry) { |os| os.write(entry[:data]) }
        end
      end
    ensure
      tw.close if tw
      gz.close if gz
    end
  end
end

desc "Build everything."
task :default => [ :tar, :gem, :clean_readonly ]
