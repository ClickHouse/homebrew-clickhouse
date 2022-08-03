class ClickhouseOdbc < Formula
  desc "Official ODBC driver implementation for accessing ClickHouse as a data source"
  homepage "https://github.com/ClickHouse/clickhouse-odbc#readme"
  url "https://github.com/ClickHouse/clickhouse-odbc.git",
    tag:      "v1.1.10.20210822",
    revision: "c7aaff6860e448acee523f5f7d3ee97862fd07d2"
  license "Apache-2.0"
  head "https://github.com/ClickHouse/clickhouse-odbc.git",
    branch:   "master"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/Altinity/homebrew-clickhouse/releases/download/clickhouse-odbc-1.1.10.20210822"
    rebuild 3
    sha256 cellar: :any, arm64_monterey: "a71b162bef10da8af86b37b9bf2a9317a7bad52065867f890cbe0a10dca3e1e4"
    sha256 cellar: :any, monterey:       "cfb1a25f373ae0ff66a3eb63c3fdd9b733b0972bd075d814e0d00cb0d31a616a"
  end

  option "with-static-runtime", "Link with the compiler and language runtime statically"

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "icu4c"
  depends_on "openssl@1.1"

  on_macos do
    depends_on "libiodbc"
  end

  on_linux do
    depends_on "gcc"
    depends_on "unixodbc"
  end

  fails_with gcc: "5"
  fails_with gcc: "6"

  def install
    cmake_args = std_cmake_args.dup

    cmake_args.reject! { |x| x.start_with?("-DCMAKE_BUILD_TYPE=") }
    cmake_args << "-DCMAKE_BUILD_TYPE=RelWithDebInfo"

    cmake_args << "-DOPENSSL_ROOT_DIR=#{Formula["openssl@1.1"].opt_prefix}"
    cmake_args << "-DICU_ROOT=#{Formula["icu4c"].opt_prefix}"

    if OS.mac?
      cmake_args << "-DODBC_PROVIDER=iODBC"
      cmake_args << "-DODBC_DIR=#{Formula["libiodbc"].opt_prefix}"
    elsif OS.linux?
      cmake_args << "-DODBC_PROVIDER=UnixODBC"
      cmake_args << "-DODBC_DIR=#{Formula["unixodbc"].opt_prefix}"
    end

    cmake_args << "-DCH_ODBC_RUNTIME_LINK_STATIC=ON" if build.with? "static-runtime"

    system "cmake", "-S", ".", "-B", "build", *cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  def caveats
    <<~EOS
      Make sure to manually configure driver and data source names to point to the installed binaries. See #{opt_share}/doc/clickhouse-odbc/config/odbc.ini.sample and #{opt_share}/doc/clickhouse-odbc/config/odbcinst.ini.sample for a sample configuration.
        ANSI driver:    #{opt_lib/shared_library("libclickhouseodbc")}
        Unicode driver: #{opt_lib/shared_library("libclickhouseodbcw")}

      If you intend to use ClickHouse ODBC driver with Tableau Desktop, consider using it together with ClickHouse ODBC Tableau connector. See https://github.com/Altinity/clickhouse-tableau-connector-odbc for more info.

      If you intend to use ClickHouse ODBC driver with Tableau Server in Linux, you need to install a variant of the driver that is linked with the compiler and language runtime statically:
        brew install --with-static-runtime altinity/clickhouse/clickhouse-odbc
    EOS
  end

  test do
    (testpath/"my.odbcinst.ini").write <<~EOS
      [ODBC Drivers]
      ClickHouse ODBC Test Driver A = Installed
      ClickHouse ODBC Test Driver W = Installed

      [ClickHouse ODBC Test Driver A]
      Description = ODBC Driver for ClickHouse (ANSI)
      Driver      = #{lib/shared_library("libclickhouseodbc")}
      Setup       = #{lib/shared_library("libclickhouseodbc")}
      UsageCount  = 1

      [ClickHouse ODBC Test Driver W]
      Description = ODBC Driver for ClickHouse (Unicode)
      Driver      = #{lib/shared_library("libclickhouseodbcw")}
      Setup       = #{lib/shared_library("libclickhouseodbcw")}
      UsageCount  = 1
    EOS

    (testpath/"my.odbc.ini").write <<~EOS
      [ODBC Data Sources]
      ClickHouse ODBC Test DSN A = ClickHouse ODBC Test Driver A
      ClickHouse ODBC Test DSN W = ClickHouse ODBC Test Driver W

      [ClickHouse ODBC Test DSN A]
      Driver      = ClickHouse ODBC Test Driver A
      Description = DSN for ClickHouse ODBC Test Driver (ANSI)
      Url         = https://default:password@example.com:8443/query?database=default

      [ClickHouse ODBC Test DSN W]
      Driver      = ClickHouse ODBC Test Driver W
      Description = DSN for ClickHouse ODBC Test Driver (Unicode)
      Url         = https://default:password@example.com:8443/query?database=default
    EOS

    ENV["ODBCSYSINI"] = testpath
    ENV["ODBCINSTINI"] = "my.odbcinst.ini"
    ENV["ODBCINI"] = "#{ENV["ODBCSYSINI"]}/my.odbc.ini"

    if OS.mac?
      ENV["ODBCINSTINI"] = "#{ENV["ODBCSYSINI"]}/#{ENV["ODBCINSTINI"]}"

      assert_match "SQL>",
        pipe_output("#{Formula["libiodbc"].bin}/iodbctest 'DSN=ClickHouse ODBC Test DSN A'", "exit\n")

      assert_match "SQL>",
        pipe_output("#{Formula["libiodbc"].bin}/iodbctestw 'DSN=ClickHouse ODBC Test DSN W'", "exit\n")
    elsif OS.linux?
      assert_match "Connected!",
        pipe_output("#{Formula["unixodbc"].bin}/isql 'ClickHouse ODBC Test DSN A'", "quit\n")

      assert_match "Connected!",
        pipe_output("#{Formula["unixodbc"].bin}/iusql 'ClickHouse ODBC Test DSN W'", "quit\n")
    end
  end
end
