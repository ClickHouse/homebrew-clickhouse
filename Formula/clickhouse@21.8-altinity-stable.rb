class ClickhouseAT218AltinityStable < Formula
  desc "Free analytics DBMS for big data with SQL interface"
  homepage "https://clickhouse.com"
  url "https://github.com/Altinity/ClickHouse.git",
    tag:      "v21.8.13.1-altinitystable",
    revision: "e7c6f6745557db3246236558306e638d3920a841"
  license "Apache-2.0"
  head "https://github.com/Altinity/ClickHouse.git",
    branch:   "releases/21.8.13"

  livecheck do
    url :stable
    regex(/^v?(21\.8(?:\.\d+)+)-altinity(?:stable|lts)$/i)
  end

  bottle do
    root_url "https://github.com/Altinity/homebrew-clickhouse/releases/download/clickhouse@21.8-altinity-stable-21.8.13.1"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "942c9115b9f3492a2394a4cf578cc6f0bb391e73900ef48cba582d74924971bc"
    sha256                               monterey:       "5272c8933e298f97160173de61faa7b981874d07579bed945464683ac56c4b3b"
  end

  keg_only :versioned_formula

  depends_on "cmake" => :build
  depends_on "gawk" => :build
  depends_on "gettext" => :build
  depends_on "git-lfs" => :build
  depends_on "libtool" => :build
  depends_on "ninja" => :build
  depends_on "perl" => :build
  depends_on "python@3.9" => :build

  on_macos do
    depends_on "llvm" => :build
  end

  on_linux do
    depends_on "llvm"
  end

  patch :DATA

  def install
    cmake_args = std_cmake_args.dup

    # It is crucial that CMake config scripts see RelWithDebInfo as a build type,
    # since the code is only handling it (and Debug) properly.
    # It is OK if Homebrew infrastructure filters out the debug info-related flags later.
    cmake_args.reject! { |x| x.start_with?("-DCMAKE_BUILD_TYPE=") }
    cmake_args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo"

    # Vanilla Clang is the only officially supported compiler.
    cmake_args << "-DCMAKE_C_COMPILER=#{Formula["llvm"].bin}/clang"
    cmake_args << "-DCMAKE_CXX_COMPILER=#{Formula["llvm"].bin}/clang++"
    cmake_args << "-DCMAKE_AR=#{Formula["llvm"].bin}/llvm-ar"
    cmake_args << "-DCMAKE_RANLIB=#{Formula["llvm"].bin}/llvm-ranlib"
    cmake_args << "-DOBJCOPY_PATH=#{Formula["llvm"].bin}/llvm-objcopy"

    # Disable more stuff that is irrelevant for production builds.
    cmake_args << "-DENABLE_CCACHE=OFF"
    cmake_args << "-DSANITIZE=OFF"
    cmake_args << "-DENABLE_TESTS=OFF"
    cmake_args << "-DENABLE_CLICKHOUSE_TEST=OFF"

    system "cmake", "-S", ".", "-B", "./build", "-G", "Ninja", *cmake_args
    system "cmake", "--build", "./build", "--config", "RelWithDebInfo", "--target", "clickhouse", "--parallel"

    system "./build/programs/clickhouse", "install", "--prefix", HOMEBREW_PREFIX, "--binary-path", prefix/"bin",
      "--user", "", "--group", ""

    # Relax the permissions when packaging.
    Dir.glob([
      etc/"clickhouse-server/**/*",
      var/"run/clickhouse-server/**/*",
      var/"log/clickhouse-server/**/*",
    ]) do |file|
      chmod 0664, file
      chmod "a+x", file if File.directory?(file)
    end
  end

  def post_install
    # Fix the permissions when deploying.
    Dir.glob([
      etc/"clickhouse-server/**/*",
      var/"run/clickhouse-server/**/*",
      var/"log/clickhouse-server/**/*",
    ]) do |file|
      chmod 0640, file
      chmod "ug+x", file if File.directory?(file)
    end

    # Make sure the data directories are initialized.
    system opt_bin/"clickhouse", "start", "--prefix", HOMEBREW_PREFIX, "--binary-path", opt_bin, "--user", ""
    system opt_bin/"clickhouse", "stop", "--prefix", HOMEBREW_PREFIX
  end

  def caveats
    <<~EOS
      If you intend to run ClickHouse server:

        - Familiarize yourself with the usage recommendations:
            https://clickhouse.com/docs/en/operations/tips/

        - Increase the maximum number of open files limit in the system:
            macOS: https://clickhouse.com/docs/en/development/build-osx/#caveats
            Linux: man limits.conf

        - Set the 'net_admin', 'ipc_lock', and 'sys_nice' capabilities on #{opt_bin}/clickhouse binary. If the capabilities are not set the taskstats accounting will be disabled. You can enable taskstats accounting by setting those capabilities manually later.
            Linux: sudo setcap 'cap_net_admin,cap_ipc_lock,cap_sys_nice+ep' #{opt_bin}/clickhouse

        - By default, the pre-configured 'default' user has an empty password. Consider setting a real password for it:
            https://clickhouse.com/docs/en/operations/settings/settings-users/

        - By default, ClickHouse server is configured to listen for local connections only. Adjust 'listen_host' configuration parameter to allow wider range of addresses for incoming connections:
            https://clickhouse.com/docs/en/operations/server-configuration-parameters/settings/#server_configuration_parameters-listen_host
    EOS
  end

  service do
    run [
      opt_bin/"clickhouse", "server",
      "--config-file", etc/"clickhouse-server/config.xml",
      "--pid-file", var/"run/clickhouse-server/clickhouse-server.pid"
    ]
    keep_alive true
    run_type :immediate
    process_type :standard
    root_dir var
    working_dir var
    log_path var/"log/clickhouse-server/stdout.log"
    error_log_path var/"log/clickhouse-server/stderr.log"
  end

  test do
    assert_match "Denis Glazachev",
      shell_output("#{bin}/clickhouse local --query 'SELECT * FROM system.contributors FORMAT TabSeparated'")
  end
end

__END__
diff --git a/programs/install/Install.cpp b/programs/install/Install.cpp
index a84bae3c9f..79763f735e 100644
--- a/programs/install/Install.cpp
+++ b/programs/install/Install.cpp
@@ -495,12 +495,12 @@ int mainEntryClickHouseInstall(int argc, char ** argv)
                 {
                     std::string data_file = config_d / "data-paths.xml";
                     WriteBufferFromFile out(data_file);
-                    out << "<clickhouse>\n"
+                    out << "<yandex>\n"
                     "    <path>" << data_path.string() << "</path>\n"
                     "    <tmp_path>" << (data_path / "tmp").string() << "</tmp_path>\n"
                     "    <user_files_path>" << (data_path / "user_files").string() << "</user_files_path>\n"
                     "    <format_schema_path>" << (data_path / "format_schemas").string() << "</format_schema_path>\n"
-                    "</clickhouse>\n";
+                    "</yandex>\n";
                     out.sync();
                     out.finalize();
                     fmt::print("Data path configuration override is saved to file {}.\n", data_file);
@@ -510,12 +510,12 @@ int mainEntryClickHouseInstall(int argc, char ** argv)
                 {
                     std::string logger_file = config_d / "logger.xml";
                     WriteBufferFromFile out(logger_file);
-                    out << "<clickhouse>\n"
+                    out << "<yandex>\n"
                     "    <logger>\n"
                     "        <log>" << (log_path / "clickhouse-server.log").string() << "</log>\n"
                     "        <errorlog>" << (log_path / "clickhouse-server.err.log").string() << "</errorlog>\n"
                     "    </logger>\n"
-                    "</clickhouse>\n";
+                    "</yandex>\n";
                     out.sync();
                     out.finalize();
                     fmt::print("Log path configuration override is saved to file {}.\n", logger_file);
@@ -525,13 +525,13 @@ int mainEntryClickHouseInstall(int argc, char ** argv)
                 {
                     std::string user_directories_file = config_d / "user-directories.xml";
                     WriteBufferFromFile out(user_directories_file);
-                    out << "<clickhouse>\n"
+                    out << "<yandex>\n"
                     "    <user_directories>\n"
                     "        <local_directory>\n"
                     "            <path>" << (data_path / "access").string() << "</path>\n"
                     "        </local_directory>\n"
                     "    </user_directories>\n"
-                    "</clickhouse>\n";
+                    "</yandex>\n";
                     out.sync();
                     out.finalize();
                     fmt::print("User directory path configuration override is saved to file {}.\n", user_directories_file);
@@ -541,7 +541,7 @@ int mainEntryClickHouseInstall(int argc, char ** argv)
                 {
                     std::string openssl_file = config_d / "openssl.xml";
                     WriteBufferFromFile out(openssl_file);
-                    out << "<clickhouse>\n"
+                    out << "<yandex>\n"
                     "    <openSSL>\n"
                     "        <server>\n"
                     "            <certificateFile>" << (config_dir / "server.crt").string() << "</certificateFile>\n"
@@ -549,7 +549,7 @@ int mainEntryClickHouseInstall(int argc, char ** argv)
                     "            <dhParamsFile>" << (config_dir / "dhparam.pem").string() << "</dhParamsFile>\n"
                     "        </server>\n"
                     "    </openSSL>\n"
-                    "</clickhouse>\n";
+                    "</yandex>\n";
                     out.sync();
                     out.finalize();
                     fmt::print("OpenSSL path configuration override is saved to file {}.\n", openssl_file);
@@ -716,25 +716,25 @@ int mainEntryClickHouseInstall(int argc, char ** argv)
                 hash_hex.resize(64);
                 for (size_t i = 0; i < 32; ++i)
                     writeHexByteLowercase(hash[i], &hash_hex[2 * i]);
-                out << "<clickhouse>\n"
+                out << "<yandex>\n"
                     "    <users>\n"
                     "        <default>\n"
                     "            <password remove='1' />\n"
                     "            <password_sha256_hex>" << hash_hex << "</password_sha256_hex>\n"
                     "        </default>\n"
                     "    </users>\n"
-                    "</clickhouse>\n";
+                    "</yandex>\n";
                 out.sync();
                 out.finalize();
                 fmt::print(HILITE "Password for default user is saved in file {}." END_HILITE "\n", password_file);
 #else
-                out << "<clickhouse>\n"
+                out << "<yandex>\n"
                     "    <users>\n"
                     "        <default>\n"
                     "            <password><![CDATA[" << password << "]]></password>\n"
                     "        </default>\n"
                     "    </users>\n"
-                    "</clickhouse>\n";
+                    "</yandex>\n";
                 out.sync();
                 out.finalize();
                 fmt::print(HILITE "Password for default user is saved in plaintext in file {}." END_HILITE "\n", password_file);
@@ -778,9 +778,9 @@ int mainEntryClickHouseInstall(int argc, char ** argv)
             {
                 std::string listen_file = config_d / "listen.xml";
                 WriteBufferFromFile out(listen_file);
-                out << "<clickhouse>\n"
+                out << "<yandex>\n"
                     "    <listen_host>::</listen_host>\n"
-                    "</clickhouse>\n";
+                    "</yandex>\n";
                 out.sync();
                 out.finalize();
                 fmt::print("The choice is saved in file {}.\n", listen_file);
