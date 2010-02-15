module Vagrant
  module Actions
    class Start < Base
      def execute!
        @vm.invoke_callback(:before_boot)

        # Startup the VM
        boot

        # Wait for it to complete booting, or error if we could
        # never detect it booted up successfully
        if !wait_for_boot
          error_and_exit(<<-error)
Failed to connect to VM! Failed to boot?
error
        end

        @vm.invoke_callback(:after_boot)
      end

      def boot
        logger.info "Booting VM..."
        @vm.vm.start(:headless, true)
      end

      def wait_for_boot(sleeptime=5)
        logger.info "Waiting for VM to boot..."

        Vagrant.config[:ssh][:max_tries].to_i.times do |i|
          logger.info "Trying to connect (attempt ##{i+1} of #{Vagrant.config[:ssh][:max_tries]})..."

          if Vagrant::SSH.up?
            logger.info "VM booted and ready for use!"
            return true
          end

          sleep sleeptime
        end

        logger.info "Failed to connect to VM! Failed to boot?"
        false
      end
    end
  end
end