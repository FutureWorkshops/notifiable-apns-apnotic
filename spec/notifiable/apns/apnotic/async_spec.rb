require 'spec_helper'

describe Notifiable::Apns::Apnotic::Async do

  subject { described_class.new(n1) }
  let(:a1) { Notifiable::App.create! name: "Drum Cussac" }
  let(:n1) { Notifiable::Notification.create! app: a1 }
  
  describe "#sandbox?" do
    before(:each) { subject.instance_variable_set("@sandbox", "1") }
    it { expect(subject.send(:sandbox?)).to eql true }
  end
  
end