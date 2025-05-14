class Ruby < Formula
  env :std  # brew_custom.sh
 
desc "Powerful, clean, object-oriented scripting language"
 

  homepage "https://www.ruby-lang.org/"
  license "Ruby"
  head "https://github.com/ruby/ruby.git", branch: "master"

  stable do
    # Consider changing the default of `Gem.default_user_install` to true with Ruby 3.5.
    # This may depend on https://github.com/rubygems/rubygems/issues/5682.
    url "https://cache.ruby-lang.org/pub/ruby/3.4/ruby-3.4.3.tar.gz"
    sha256 "55a4cd1dcbe5ca27cf65e89a935a482c2bb2284832939266551c0ec68b437f46"

    # Should be updated only when Ruby is updated (if an update is available).
    # The exception is Rubygem security fixes, which mandate updating this
    # formula & the versioned equivalents and bumping the revisions.
    resource "rubygems" do
      url "https://rubygems.org/rubygems/rubygems-3.6.8.tgz"
      sha256 "da5340b42ba3ddc5ede4a6b948ffa5b409d48cb119e2937e27e4c0b13bf9c390"

      livecheck do
        url "https://rubygems.org/pages/download"
        regex(/href=.*?rubygems[._-]v?(\d+(?:\.\d+)+)\.t/i)
      end
    end
  end

  livecheck do
    url "https://www.ruby-lang.org/en/downloads/releases/"
    regex(/href=.*?ruby[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_sequoia: "086e24aeb4d3563ec7b0cb82cf96d4f54343aecc764d370e1958f04cc5c23585"
    sha256 arm64_sonoma:  "bf92cea06b2fcedc64bcde22b4054bbdc5373ada4073a1d930b1d797fe80244d"
    sha256 arm64_ventura: "32a5b8b77db04d6e1f2b5fa0859a795ca6be8a34402eb1413e4b3ebd26449587"
    sha256 sonoma:        "0ae2e985d6d5e687a7b8f4f48f04783326012090f290fe53cd0a6f7f9df2ecc4"
    sha256 ventura:       "8ff27dfe6332165600743bc73020da9148a3f1d20d49e9d8a87771baeb71c39b"
    sha256 arm64_linux:   "f37b0efd457c9d5e5351436f0b03a9b64cb5e580170be2b9966517d664a2513e"
    sha256 x86_64_linux:  "e2d2ed80d9a01a34ad96a3c2370b5430a9bf22de03aae18bd0fe847a9d29a6b8"
  end

  keg_only :provided_by_macos

  depends_on "autoconf" => :build
  depends_on "pkgconf" => :build
  depends_on "rust" => :build
  depends_on "libyaml"
  depends_on "openssl@3"

  uses_from_macos "gperf"
  uses_from_macos "libffi"
  uses_from_macos "libxcrypt"
  uses_from_macos "zlib"

  def determine_api_version
    Utils.safe_popen_read(bin/"ruby", "-e", "print Gem.ruby_api_version")
  end

  def api_version
    if head?
      if latest_head_prefix
        determine_api_version
      else
        # Best effort guess
        "#{stable.version.major.to_i}.#{stable.version.minor.to_i + 1}.0+0"
      end
    else
      "#{version.major.to_i}.#{version.minor.to_i}.0"
    end
  end

  def rubygems_bindir
    HOMEBREW_PREFIX/"lib/ruby/gems/#{api_version}/bin"
  end

  def install
    ENV["CC"] = "/usr/local/opt/llvm/bin/clang"  # brew_custom.sh
    ENV["CXX"] = "/usr/local/opt/llvm/bin/clang++"  # brew_custom.sh
    ENV["OBJC"] = "/usr/local/opt/llvm/bin/clang"  # brew_custom.sh
    ENV["OBJCXX"] = "/usr/local/opt/llvm/bin/clang++"  # brew_custom.sh    
    ENV["HOMEBREW_CMAKE_ARGS"] = "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"  # brew_custom.sh
    ENV["CMAKE_POLICY_VERSION_MINIMUM"] = "3.5"  # brew_custom.sh
    ENV["ACLOCAL_PATH"] = "/usr/local/share/aclocal:/usr/local/Homebrew/Library/Homebrew/os/mac/aclocal"  # brew_custom.sh
    ENV["CFLAGS"] = "-O2 -g0 -pipe -march=native"  # brew_custom.sh
    ENV["CXXFLAGS"] = "-O2 -g0 -pipe -march=native -Xlinker -no_warn_duplicate_libraries"  # brew_custom.sh
    ENV["HOMEBREW_RUBY_PATH"] = "/usr/local/Homebrew/Library/Homebrew/vendor/portable-ruby/current/bin/ruby"  # brew_custom.sh
    ENV["CMAKE_INCLUDE_PATH"] = "/usr/local/include:/usr/local/opt/openssl@3/include:/usr/local/opt/libyaml/include:/Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk/System/Library/Frameworks/OpenGL.framework/Versions/Current/Headers"  # brew_custom.sh
    ENV["CMAKE_LIBRARY_PATH"] = "/usr/local/lib:/usr/local/opt/openssl@3/lib:/usr/local/opt/libyaml/lib:/Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk/System/Library/Frameworks/OpenGL.framework/Versions/Current/Libraries"  # brew_custom.sh
    ENV["PKG_CONFIG_LIBDIR"] = "/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/Homebrew/Library/Homebrew/os/mac/pkgconfig/11:/usr/lib/pkgconfig"  # brew_custom.sh
    ENV["PKG_CONFIG_PATH"] = "/usr/local/lib/pkgconfig:/usr/local/share/pkgconfig:/usr/local/opt/llvm@20/lib/pkgconfig:/usr/local/opt/llvm@19/lib/pkgconfig:/usr/local/opt/llvm@18/lib/pkgconfig:/usr/local/opt/icu4c@77:/Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk/usr/lib/pkgconfig:/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX11.sdk/usr/lib/pkgconfig"  # brew_custom.sh
    ENV["HOMEBREW_NO_ENV_FILTERS"] = "rdoc"  # brew_custom.sh
    ENV["LDFLAGS"] = "-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk -L/usr/local/lib -Wl,-headerpad_max_install_names -Wl,-dead_strip_dylibs -L/usr/local/opt/openssl@3/lib -L/usr/local/opt/libyaml/lib -O2 -g0 -w -pipe -march=native -Wl,-export_dynamic"  # brew_custom.sh
    ENV["CPPFLAGS"] = "-isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX11.sdk -I/usr/local/include -I/usr/local/opt/openssl@3/include -I/usr/local/opt/libyaml/include -D_FORTIFY_SOURCE=2 -D_XOPEN_SOURCE=1 -fstack-protector-strong -fPIC -O2 -g0 -w -pipe -march=native"  # brew_custom.sh
    ENV["CC"] = "/usr/local/opt/llvm/bin/clang"  # brew_custom.sh
    ENV["CXX"] = "/usr/local/opt/llvm/bin/clang++"  # brew_custom.sh
    ENV["OBJC"] = "/usr/local/opt/llvm/bin/clang"  # brew_custom.sh
    ENV["OBJCXX"] = "/usr/local/opt/llvm/bin/clang++"  # brew_custom.sh
    ENV["MACOSX_DEPLOYMENT_TARGET"] = "11.7"  # brew_custom.sh

    ENV.delete("SDKROOT")  

    # Prevent `make` from trying to install headers into the SDK
    # TODO: Remove this workaround when the following PR is merged/resolved:
    #       https://github.com/Homebrew/brew/pull/12508
    inreplace "tool/mkconfig.rb", /^(\s+val = )'"\$\(SDKROOT\)"'\+/, "\\1"

    system "./autogen.sh" if build.head?

    # system "rm -rf ext/ripper"

    paths = %w[libyaml openssl@3].map { |f| Formula[f].opt_prefix }
    args = %W[
      --prefix=#{prefix}
      --enable-shared
      --disable-silent-rules
      --with-sitedir=#{HOMEBREW_PREFIX}/lib/ruby/site_ruby
      --with-vendordir=#{HOMEBREW_PREFIX}/lib/ruby/vendor_ruby
      --with-opt-dir=#{paths.join(":")}
      --without-gmp
      --disable-install-doc  
    ] #<<-------------ADDED --disable-install-doc!!!!!!!!
    
    args << "--with-baseruby=#{RbConfig.ruby}" if build.head?
    args << "--disable-dtrace" if OS.mac? && !MacOS::CLT.installed?

    # Correct MJIT_CC to not use superenv shim
    args << "MJIT_CC=/usr/bin/#{DevelopmentTools.default_compiler}"

    # ENV.append "LDFLAGS", "-Wl,-export_dynamic"

    system "./configure", *args

    # Ruby has been configured to look in the HOMEBREW_PREFIX for the
    # sitedir and vendordir directories; however we don't actually want to create
    # them during the install.
    #
    # These directories are empty on install; sitedir is used for non-rubygems
    # third party libraries, and vendordir is used for packager-provided libraries.
    inreplace "tool/rbinstall.rb" do |s|
      s.gsub! 'prepare "extension scripts", sitelibdir', ""
      s.gsub! 'prepare "extension scripts", vendorlibdir', ""
      s.gsub! 'prepare "extension objects", sitearchlibdir', ""
      s.gsub! 'prepare "extension objects", vendorarchlibdir', ""
    end
    
    system "make"

 # Patch RubyGems hook to disable RDoc generation before setup is run.
 # rubygems_hook = "rdoc/rubygems_hook.rb"
 # if File.exist?(rubygems_hook)
 # inreplace rubygems_hook, /def generate.*end/m, "def generate; end"
 # ohai "RubyGems hook patched to skip documentation generation."
 # end
  
  # Remove any native ripper.extension if it exists.
 # rm_f "#{buildpath}/lib/ruby/3.4.0/x86_64-darwin20/ripper.bundle" if File.exist?("#{buildpath}/lib/ruby/3.4.0/x86_64-darwin20/ripper.bundle")
  
  # Then create the dummy ripper file...
  # rm_f "lib/ripper.rb"
  
# ohai "Expanding dummy ripper file to bypass missing constants..."
# dummy_ripper = "lib/ripper.rb"
# File.open(dummy_ripper, "w") do |f|
#  f.puts <<~RUBY
#    module Ripper
#      EXPR_BEG       = 0
#      EXPR_END       = 0
#      EXPR_ENDFN     = 0
#      EXPR_ARG       = 0
#      EXPR_CMDARG    = 0
#      EXPR_ARG2      = 0
#      EXPR_ENDARG    = 0
#      EXPR_FNAME     = 0
#      EXPR_DOT       = 0
#      EXPR_ENDLABEL  = 0
#
#      def self.lex(*args)
#        []
#      end
#
#      def self.sexp(*args)
#        nil
#      end
#
#       # Force override of Ripper.parse:
#        class << self
#          # Undefine an existing :parse if it exists.
#          remove_method(:parse) if method_defined?(:parse)
#          def parse(*args)
#            puts "Using dummy Ripper.parse (arity = \#{method(:parse).arity})"
#            # Return a dummy token structure.
#            [["on_ident", "dummy", [:ident, nil]], ["on_sp", " ", [:space, nil]]]
#          end
#        end
#
#      # Adding a dummy `Filter` class to prevent NameError
#      class Filter
#        def initialize(*args); end
#        def parse; end
#      end
#    end
#  RUBY
# end

    system "make", "install"

    # A newer version of ruby-mode.el is shipped with Emacs
    elisp.install Dir["misc/*.el"].reject { |f| f == "misc/ruby-mode.el" }

    if OS.linux?
      arch = Utils.safe_popen_read(
        bin/"ruby", "-rrbconfig", "-e", 'print RbConfig::CONFIG["arch"]'
      ).chomp
      # Don't restrict to a specific GCC compiler binary we used (e.g. gcc-5).
      inreplace lib/"ruby/#{api_version}/#{arch}/rbconfig.rb" do |s|
        s.gsub! ENV.cxx, "c++"
        s.gsub! ENV.cc, "cc"
        # Change e.g. `CONFIG["AR"] = "gcc-ar-11"` to `CONFIG["AR"] = "ar"`
        s.gsub!(/(CONFIG\[".+"\] = )"(?:gcc|g\+\+)-(.*)-\d+"/, '\\1"\\2"')
      end
    end

    unless build.head? # Use bundled RubyGems for --HEAD (will be newer)
      # This is easier than trying to keep both current & versioned Ruby
      # formulae repeatedly updated with Rubygem patches.
      resource("rubygems").stage do
        ENV.prepend_path "PATH", bin

        system "#{bin}/ruby", "setup.rb", "--prefix=#{buildpath}/vendor_gem", "--no-rdoc", "--no-ri" #<<<----------- MAGIC LINE!!!!
        rg_in = lib/"ruby/#{api_version}"
        rg_gems_in = lib/"ruby/gems/#{api_version}"

        # Remove bundled Rubygem and Bundler
        rm_r rg_in/"bundler"
        rm rg_in/"bundler.rb"
        rm_r Dir[rg_gems_in/"gems/bundler-*"]
        rm Dir[rg_gems_in/"specifications/default/bundler-*.gemspec"]
        rm_r rg_in/"rubygems"
        rm rg_in/"rubygems.rb"
        rm bin/"gem"

        # Drop in the new version.
        rg_in.install Dir[buildpath/"vendor_gem/lib/*"]
        (rg_gems_in/"gems").install Dir[buildpath/"vendor_gem/gems/*"]
        (rg_gems_in/"specifications/default").install Dir[buildpath/"vendor_gem/specifications/default/*"]
        bin.install buildpath/"vendor_gem/bin/gem" => "gem"
        bin.install buildpath/"vendor_gem/bin/bundle" => "bundle"
        bin.install buildpath/"vendor_gem/bin/bundler" => "bundler"
      end
    end

    # Customize rubygems to look/install in the global gem directory
    # instead of in the Cellar, making gems last across reinstalls
    config_file = lib/"ruby/#{api_version}/rubygems/defaults/operating_system.rb"
    config_file.write rubygems_config
  end

  def post_install
    # Since Gem ships Bundle we want to provide that full/expected installation
    # but to do so we need to handle the case where someone has previously
    # installed bundle manually via `gem install`.
    rm(%W[
      #{rubygems_bindir}/bundle
      #{rubygems_bindir}/bundler
    ].select { |file| File.exist?(file) })
    rm_r(Dir[HOMEBREW_PREFIX/"lib/ruby/gems/#{api_version}/gems/bundler-*"])
  end

  def rubygems_config
    <<~RUBY
      module Gem
        class << self
          alias :old_default_dir :default_dir
          alias :old_default_path :default_path
          alias :old_default_bindir :default_bindir
          alias :old_ruby :ruby
          alias :old_default_specifications_dir :default_specifications_dir
        end

        def self.default_dir
          path = [
            "#{HOMEBREW_PREFIX}",
            "lib",
            "ruby",
            "gems",
            RbConfig::CONFIG['ruby_version']
          ]

          @homebrew_path ||= File.join(*path)
        end

        def self.private_dir
          path = if defined? RUBY_FRAMEWORK_VERSION then
                   [
                     File.dirname(RbConfig::CONFIG['sitedir']),
                     'Gems',
                     RbConfig::CONFIG['ruby_version']
                   ]
                 elsif RbConfig::CONFIG['rubylibprefix'] then
                   [
                    RbConfig::CONFIG['rubylibprefix'],
                    'gems',
                    RbConfig::CONFIG['ruby_version']
                   ]
                 else
                   [
                     RbConfig::CONFIG['libdir'],
                     ruby_engine,
                     'gems',
                     RbConfig::CONFIG['ruby_version']
                   ]
                 end

          @private_dir ||= File.join(*path)
        end

        def self.default_path
          if Gem.user_home && File.exist?(Gem.user_home)
            [user_dir, default_dir, old_default_dir, private_dir]
          else
            [default_dir, old_default_dir, private_dir]
          end
        end

        def self.default_bindir
          "#{rubygems_bindir}"
        end

        def self.ruby
          "#{opt_bin}/ruby"
        end

        # https://github.com/Homebrew/homebrew-core/issues/40872#issuecomment-542092547
        # https://github.com/Homebrew/homebrew-core/pull/48329#issuecomment-584418161
        def self.default_specifications_dir
          File.join(Gem.old_default_dir, "specifications", "default")
        end
      end
    RUBY
  end

  def caveats
    <<~EOS
      By default, binaries installed by gem will be placed into:
        #{rubygems_bindir}

      You may want to add this to your PATH.
    EOS
  end

  test do
    hello_text = shell_output("#{bin}/ruby -e 'puts :hello'")
    assert_equal "hello\n", hello_text

    assert_equal api_version, determine_api_version

    ENV["GEM_HOME"] = testpath
    system bin/"gem", "install", "json"

    (testpath/"Gemfile").write <<~EOS
      source 'https://rubygems.org'
      gem 'github-markup'
    EOS
    system bin/"bundle", "exec", "ls" # https://github.com/Homebrew/homebrew-core/issues/53247
    system bin/"bundle", "install", "--binstubs=#{testpath}/bin"
    assert_path_exists testpath/"bin/github-markup", "github-markup is not installed in #{testpath}/bin"
  end
end
