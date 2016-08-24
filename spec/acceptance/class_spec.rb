if ENV['BEAKER'] == 'true'
  # running in BEAKER test environment
  require 'spec_helper_acceptance'
else
  # running in non BEAKER environment
  require 'serverspec'
  set :backend, :exec
end

describe 'profile_apache class' do

  context 'default parameters' do
    if ENV['BEAKER'] == 'true'
      # Using puppet_apply as a helper
      it 'should work with no errors' do
        pp = <<-EOS
        class { 'profile_apache': }
        EOS

        # Run it
        apply_manifest(pp, :catch_failures => true, :future_parser => true)
      end
    end

  describe host('8.8.8.8') do
    it { should be_reachable }
    it { should be_reachable.with( :port => 53, :proto => 'udp' ) }
  end
  
  describe package('apache2') do
    it { is_expected.to be_installed }
  end

  describe service('apache2') do
    it { is_expected.to be_enabled }
    it { is_expected.to be_running }
  end

  describe port(80) do
    it { should be_listening }
  end

  describe port(443) do
    it { should be_listening }
  end

  end
end
