module PkgForge
  ##
  # Helpers for pushing
  module Push
    include Contracts::Core
    include Contracts::Builtin

    private

    Contract None => nil
    def bump_revision!
      new_revision = File.read('version').to_i + 1
      File.open('version', 'w') { |fh| fh << "#{new_revision}\n" }
      nil
    end

    Contract None => nil
    def update_repo!
      run_local "git commit -am '#{full_version}'"
      run_local "git tag -f '#{full_version}'"
      cache_hostkey!
      run_local 'git push --tags origin master'
      sleep 2
      nil
    end

    Contract None => nil
    def upload_artifact!
      run_local [
        'targit',
        '--authfile', '.github',
        '--create',
        '--name', "#{name}.tar.gz",
        "#{org}/#{name}", full_version, tmpfile(:tarball)
      ]
      nil
    end

    Contract None => nil
    def cache_hostkey!
      cmd = 'ssh -oStrictHostKeyChecking=no git@github.com &> /dev/null || true'
      run_local cmd
    end
  end
end
