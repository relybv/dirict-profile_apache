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

    describe group('notarisdossier') do
      it { should exist }
    end

    describe user('notarisdossier') do
      it { should belong_to_primary_group 'notarisdossier' }
    end

    describe file('/home/notarisdossier') do
      it { should be_owned_by 'notarisdossier' }
    end

    describe file('/home/notarisdossier/.ssh') do
      it { should be_owned_by 'notarisdossier' }
    end

    describe file('/home/notarisdossier/.ssh/authorized_keys') do
      it { should be_owned_by 'notarisdossier' }
      it { should be_mode 600 }
    end

    describe file('/home/notarisdossier/sessions') do
      it { should be_owned_by 'notarisdossier' }
      it { should be_mode 777 }
    end

    describe file('/home/notarisdossier/redirect') do
      it { should be_owned_by 'notarisdossier' }
      it { should be_mode 750 }
    end

    describe file('/home/notarisdossier/application/current') do
      it { should be_owned_by 'notarisdossier' }
    end

    describe file('/home/notarisdossier/config') do
      it { should be_owned_by 'notarisdossier' }
    end

    describe file('/home/notarisdossier/office-templates') do
      it { should be_owned_by 'notarisdossier' }
    end

    describe file('/home/notarisdossier/errors') do
      it { should be_owned_by 'notarisdossier' }
    end

    describe file('/home/notarisdossier/logs') do
      it { should be_owned_by 'notarisdossier' }
    end

    describe file('/home/notarisdossier/redirect/index.html') do
      it { should be_owned_by 'notarisdossier' }
      it { should be_grouped_into 'www-data' }
      it { should be_mode 640 }
      its(:content) { should match /META HTTP-EQUIV="Refresh"/ }
    end

    describe file('/home/notarisdossier/application/releases/dummy/frontends/office/public/working.html') do
      it { should be_owned_by 'notarisdossier' }
      it { should be_grouped_into 'www-data' }
      it { should be_mode 640 }
      its(:content) { should match /<!DOCTYPE html>/ }
    end

  end
end
