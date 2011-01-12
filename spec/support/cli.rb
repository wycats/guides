require "guides"
require "guides/cli"

module SpecHelpers
  attr_reader :stdin, :stdout, :stderr

  def env
    @env ||= {}
  end

  def guides(*argv)
    opts = Hash === argv.last ? argv.pop : {}

    kill!
    create_pipes

    @pid = Process.fork do
      Dir.chdir opts[:chdir] if opts[:chdir]

      @stdout.close
      @stdin.close
      @stderr.close

      STDOUT.reopen @stdout_child
      STDIN.reopen  @stdin_child

      if opts[:track_stderr] || argv.first == 'preview'
        STDERR.reopen @stderr_child
      end

      env.each do |key, val|
        ENV[key] = val
      end

      Guides::CLI.start(argv)
    end

    if argv.first == 'preview'
      wait_for_preview_server
    end

    @stdout_child.close
    @stdin_child.close
    @stderr_child.close
    @pid
  end

  def wait_for_preview_server
    s = TCPSocket.new('0.0.0.0', 9292)
  rescue Errno::ECONNREFUSED
    sleep 0.2
    retry
  ensure
    s.close
  end

  def out_until_block(io = stdout)
    # read 1 first so we wait until the process is done processing the last write
    chars = nil

    IO.select( [ io ] )

    chars = io.read(1)
    sleep 0.05

    loop do
      chars << io.read_nonblock(1000)
      sleep 0.05
    end
  rescue Errno::EAGAIN, EOFError => e
    chars || ""
  end

  def input(line, opts = {})
    if on = opts[:on]
      should_block_on on
    end
    stdin << "#{line}\n"
  end

  def wait
    return unless @pid

    pid, status = Process.wait2(@pid, 0)

    @exit_status = status
    @pid = nil
  end

  def exit_status
    wait
    @exit_status
  end

  def kill!
    Process.kill(9, @pid) if @pid
  end

  def out
    stdout.read
  end

  def err
    stderr.read
  end

  def create_pipes
    @stdout, @stdout_child = IO.pipe
    @stdin_child, @stdin   = IO.pipe
    @stderr, @stderr_child = IO.pipe
  end
end

