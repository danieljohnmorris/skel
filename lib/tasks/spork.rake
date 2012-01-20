require 'spork'
require 'spork/runner'

#
# Control your Spork servers with easy to use commands. It support both RSpec
# and Cucumber. Both servers can be run in parallel and controlled individually.
#
# @note Ensure that spork >= 0.9.0rc is installed to use all functionalities.
#
# @example Control the Spork servers with:
#
# rake spork:start             #=> Starts two Spork servers, RSpec & Cucumber
# rake spork:stop              #=> Stops both server processes
# rake spork:restart           #=> Stops and starts both servers anew
#
# rake spork:start:rspec       #=> Only start the RSpec Spork server instance
# rake spork:restart:cucumber  #=> Restart the Cucumber Spork server
#
# rake spork:status            #=> Displays the current Spork server status
#
namespace :spork do

  # -------------------------------------------- #
  #                    Config                    #
  # -------------------------------------------- #

  @timeout      = 20
  @project_dir  = File.expand_path("../../../", __FILE__)
  @pid_dir      = File.join("tmp/pids")
  @rspec_pid    = File.join(@project_dir, @pid_dir, "spork_rspec.pid")
  @cucumber_pid = File.join(@project_dir, @pid_dir, "spork_cucumber.pid")

  # -------------------------------------------- #
  #                     Start                    #
  # -------------------------------------------- #

  namespace :start do
    desc "Start the Spork server for RSpec"
    task :rspec do
      begin
        print "Starting Spork for RSpec...\n"
        pid = suppress_output { run_spork(["rspec"]) }
        wait_for_rails(@timeout)
        write_pid_file(@rspec_pid, pid) if running?(pid)
        show_rspec_status
      rescue StandardError => e
        show_error_encountered(e)
      end
    end

    desc "Start the Spork server for Cucumber"
    task :cucumber do
      begin
        print "Starting Spork for Cucumber...\n"
        pid = suppress_output { run_spork(["cucumber"]) }
        wait_for_rails(@timeout)
        write_pid_file(@cucumber_pid, pid) if running?(pid)
        show_cucumber_status
      rescue StandardError => e
        show_error_encountered(e)
      end
    end
  end

  desc "Start both Spork servers, for RSpec and Cucumber"
  multitask start: ["start:rspec", "start:cucumber"]

  # -------------------------------------------- #
  #                     Stop                     #
  # -------------------------------------------- #

  namespace :stop do
    desc "Stop the Spork server for RSpec"
    task :rspec do
      print "Stopping Spork for RSpec...\n"
      if File.exists?(@rspec_pid)
        begin
          kill_spork(@rspec_pid)
          rm(@rspec_pid, verbose: false)
          show_rspec_status("STOPPED")
        rescue Errno::ESRCH
          rm(@rspec_pid, verbose: false)
          show_rspec_status
        rescue StandardError => e
          show_error_encountered(e)
        end
      else
        show_rspec_status
      end
    end

    desc "Stop the Spork server for Cucumber"
    task :cucumber do
      print "Stopping Spork for Cucumber...\n"
      if File.exists?(@cucumber_pid)
        begin
          kill_spork(@cucumber_pid)
          rm(@cucumber_pid, verbose: false)
          show_cucumber_status("STOPPED")
        rescue Errno::ESRCH
          rm(@cucumber_pid, verbose: false)
          show_cucumber_status
        rescue StandardError => e
          show_error_encountered(e)
        end
      else
        show_cucumber_status
      end
    end
  end

  desc "Stop both Spork servers, for RSpec and Cucumber"
  multitask stop: ["stop:rspec", "stop:cucumber"]

  # -------------------------------------------- #
  #                   Restart                    #
  # -------------------------------------------- #

  namespace :restart do
    desc "Restart the Spork server for RSpec"
    task rspec: ["stop:rspec", "start:rspec"]

    desc "Restart the Spork server for Cucumber"
    task cucumber: ["stop:cucumber", "start:cucumber"]
  end

  desc "Restart both Spork servers, for RSpec and Cucumber"
  multitask restart: ["restart:rspec", "restart:cucumber"]

  # -------------------------------------------- #
  #                    Status                    #
  # -------------------------------------------- #

  desc "Displays the current status of all Spork servers"
  task :status do
    show_rspec_status
    show_cucumber_status
  end

  # -------------------------------------------- #
  #                Helper Methods                #
  # -------------------------------------------- #

  #
  # Spawns a Spork server with the supplied options.
  #
  # The server process will be detached from the Rake task so it doesn't get
  # terminated when Ruby finishes processing the task.
  #
  # @param [Array] options Spork server options
  # @return [Fixnum] the PID assigned by the operating system
  #
  def run_spork(options = [])
    pid = fork { Spork::Runner.run(options, $stdout, $stderr) }
    Process.detach(pid)
    pid
  end

  #
  # Kills a Spork server process, identified by a PID in a given PID file.
  #
  # @note This method should be wrapped inside a begin/end block in order
  # to rescue a possible, but harmless Errno::ESRCH. This error means that the
  # operating system couldn't find the process.
  #
  # @param [String] pid_file the .pid file that contains the PID number
  # @return [Fixnum] the PID number that has been killed
  #
  def kill_spork(pid_file)
    pid = File.read(pid_file).to_i
    Process.kill("INT", pid); sleep 1
    pid
  end

  #
  # Checks whether process with a given PID is running on the system.
  #
  # @param [Fixnum] pid the PID number to be checked
  # @return [Boolean]
  #
  def running?(pid)
    begin
      return true if Process.getpgid(pid)
    rescue Errno::ESRCH
      false
    end
  end

  #
  # Writes a given PID number to a given .pid file inside the pid directory.
  # It ensures, that the directory exists before it writes.
  #
  # @param [String] pid_file the .pid file to be written to
  # @param [Fixnum] pid the PID number to be written
  # @return [Fixnum] the number of bytes written
  #
  def write_pid_file(pid_file, pid)
    directory @pid_dir
    File.open(pid_file, "w") { |file| file.write pid }
  end

  #
  # Suppress all output to STDOUT and STDERR for the duration of the block.
  #
  # @yield the code which should be suppressed
  # @return [Object] the result of the block given
  #
  def suppress_output(&block)
    $stdout = File.new("/dev/null", "w")
    $stderr = File.new("/dev/null", "w")
    result = block.call
    $stdout = STDOUT
    $stderr = STDERR
    result
  end

  #
  # Queries the status of a .pid file and return a well formed string meant
  # for console output.
  #
  # @param [String] pid_file the .pid file to be examined and checked
  # @param [String] text overrides the default status message
  # @return [String] success, warning or error message
  #
  def status(pid_file, text)
    if File.exists?(pid_file)
      pid = File.read(pid_file).to_i
      if running?(pid)
        "\033[32m[#{text || "RUNNING"}]\033[0m (PID: #{pid})"
      else
        pid_filepath = File.join(@pid_dir, File.basename(pid_file))
        "\033[31m[#{text || "ZOMBIE PID FILE"}]\033[0m (#{pid_filepath})"
      end
    else
      "\033[33m[#{text || "NOT RUNNING"}]\033[0m"
    end
  end

  #
  # Displays the status for Spork's RSpec server.
  #
  # @param [String] text overrides the default status message
  # @return [NilClass]
  #
  def show_rspec_status(text = nil)
    print "Spork RSpec:    #{status(@rspec_pid, text)}\n"
  end

  #
  # Displays the status for Spork's Cucumber server.
  #
  # @param [String] text overrides the default status message
  # @return [NilClass]
  #
  def show_cucumber_status(text = nil)
    print "Spork Cucumber: #{status(@cucumber_pid, text)}\n"
  end

  #
  # Displays an error message for the given error.
  #
  # @param [Exception] error an error object with Exception in its ancestor line
  # @return [NilClass]
  #
  def show_error_encountered(error)
    print "\033[31mError encountered:\033[0m\n"
    print error.inspect
  end

  #
  # Notify the user that Rails is given some time to load.
  #
  # @param [Fixnum] seconds number of seconds to wait
  # @return [Fixnum] the number of seconds waited
  #
  def wait_for_rails(seconds)
    print "Giving Rails #{seconds} seconds to load...\n"
    sleep seconds
  end
end

# -------------------------------------------- #
#               Spork Base Task                #
# -------------------------------------------- #

task spork: ["spork:status"] do
  print "\n"
  print "Use `rake -T spork` to see all available tasks for Spork.\n"
end