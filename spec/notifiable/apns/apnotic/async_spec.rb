require 'spec_helper'

describe Notifiable::Apns::Apnotic::Async do

  let(:app) { create(:app) }
  let(:notification) { create(:notification, app: app) }
  let(:device) { create(:device_token, app: app, provider: :apns) }
  subject { described_class.new(notification) }
  
  describe "#sandbox?" do
    before(:each) { subject.instance_variable_set("@sandbox", "1") }
    it { expect(subject.send(:sandbox?)).to eql true }
  end
  
  describe "#enqueue" do
    let(:connection) { instance_double(Apnotic::Connection) }
    let(:push) { instance_double(Apnotic::Push) }
    let(:push_async_error) { nil }
    
    before(:each) do
      allow(subject).to receive(:connection) { connection }

      if(push_async_error)
        expect(connection).to receive(:prepare_push).twice { push }
        expect(push).to receive(:on).twice { }
        
        @times_called = 0
        allow(connection).to receive(:push_async) do
          @times_called += 1
          raise push_async_error if @times_called == 1
        end
      else
        expect(connection).to receive(:prepare_push) { push }
        expect(push).to receive(:on) { }
        expect(connection).to receive(:push_async) { }
      end
      
      subject.bundle_id = "com.example.Example"
      subject.certificate = File.open(File.join(File.dirname(__FILE__), "..", "..", "..", "fixtures", "apns-development.pem")).read
      subject.send(:enqueue, device, notification)
    end
    
    context 'normal device' do
      it { expect(1).to eq 1 }
    end
    
    context 'connection error' do
      let(:push_async_error) { SocketError.new('Socket was remotely closed') }
      it { expect(1).to eq 1 }
    end
  end
  
  describe '#build_notification' do    
    before(:each) { @payload = subject.send(:build_notification, device, notification) }
    context 'app save_delivery_statuses is true' do
      let(:app) { create(:app, configuration: { save_notification_statuses: true }) }
      it { expect(@payload.mutable_content).to eq true }
    end
    
    context 'app save_delivery_statuses is false' do
      let(:app) { create(:app, configuration: { save_notification_statuses: false }) }
      it { expect(@payload.mutable_content).to eq false }
    end
    
    context 'default sound' do
      let(:notification) { create(:notification, app: app, title: 'New offers') }
      it { expect(@payload.sound).to eq 'default' }
    end
    
    context 'infer priority and sound' do
      let(:notification) { create(:notification, app: app, content_available: true) }
      it { expect(@payload.priority).to eq 5 }
      it { expect(@payload.sound).to eq nil }
    end
  end
  
  describe '#process_response' do
    let(:device) { create(:device_token) }
    context 'ok' do
      let(:response) { instance_double(Apnotic::Response, 'ok?': true) }
      before(:each) do
        expect(subject).to receive(:processed).with(device)
        subject.send(:process_response, response, device)
      end 
      it { expect(1).to eq 1 }   
    end
    
    context '410' do
      let(:response) { instance_double(Apnotic::Response, 'ok?': false, status: '410', body: {'reason' => 'NotFound'}) }
      before(:each) do
        expect(subject).to receive(:processed).with(device, '410', 'NotFound')
        subject.send(:process_response, response, device)
      end 
      it { expect(device.destroyed?).to eq true }   
    end
    
    
    context '400 BadDeviceToken' do
      let(:response) { instance_double(Apnotic::Response, 'ok?': false, status: '400', body: {'reason' => 'BadDeviceToken'}) }
      before(:each) do
        expect(subject).to receive(:processed).with(device, '400', 'BadDeviceToken')
        subject.send(:process_response, response, device)
      end 
      it { expect(device.destroyed?).to eq true }   
    end
    
    context '400 DeviceTokenNotForTopic' do
      let(:response) { instance_double(Apnotic::Response, 'ok?': false, status: '400', body: {'reason' => 'DeviceTokenNotForTopic'}) }
      before(:each) do
        expect(subject).to receive(:processed).with(device, '400', 'DeviceTokenNotForTopic')
        subject.send(:process_response, response, device)
      end 
      it { expect(device.destroyed?).to eq true }   
    end
  end
  
  describe '#flush' do
    let(:feedback) { double(:feedback, each: []) }
    before(:each) { allow(subject).to receive(:grocer_feedback) { feedback } }
    it { expect(subject.send(:process_feedback)).to eq [] }
  end
  
end