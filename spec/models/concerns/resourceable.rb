require 'spec_helper'

shared_examples_for 'resourceable' do

  describe '#save_resources' do

    let!(:token) { FactoryGirl.create model }

    describe 'with nil resources' do

      before { token.save_resources(nil) }

      it 'sets devices with an empty array' do
        token.reload.devices.should == []
      end
    end

    describe 'with empty resources' do

      let(:resources) do
        { devices: [], locations: [] }
      end

      before { token.save_resources(resources) }

      it 'sets devices with an empty array' do
        token.reload.devices.should == []
      end
    end

    describe 'with locations' do

      let(:house)     { FactoryGirl.create :house, :with_descendants }
      let(:device_id) { Moped::BSON::ObjectId('000aa0a0a000a00000000007') }
      let(:summer)    { FactoryGirl.create :house, name: 'Summer house', devices: [ device_id ] }
      let(:locations) { [ house.id, summer.id ] }
      let(:resources) { { devices: [], locations: locations } }

      before { token.save_resources(resources) }

      describe 'when sets devices with the list of devices in the houses' do

        let(:devices) { house.all_devices + summer.all_devices }

        it 'sets the house devices' do
          token.reload.devices.should == devices
        end
      end
    end

    describe 'with list of devices' do

      let(:light)     { FactoryGirl.create :light  }
      let(:dimmer)    { FactoryGirl.create :device, name: 'Dimmer' }
      let(:other)     { FactoryGirl.create :device, name: 'Other' }
      let(:devices)   { [ light.id, dimmer.id ] }
      let(:resources) { { devices: devices, locations: [] } }

      before { token.save_resources(resources) }

      it 'sets devices with the list of devices' do
        token.reload.devices.should == devices
      end

      describe 'with locations' do

        let(:house)     { FactoryGirl.create :house, :with_descendants }
        let(:locations) { [ house.id ] }
        let(:resources) { { devices: devices, locations: locations } }
        let(:list)      { devices + house.all_devices }

        before { token.save_resources(resources) }

        it 'sets device with all devices' do
          token.reload.devices.should == list
        end

        describe 'with common devices' do

          let(:summer) { FactoryGirl.create :house, name: 'Summer house', devices: [ light.id ] }
          let(:locations) { [ house.id, summer.id ] }

          before { token.save_resources(resources) }

          it 'sets device with all devices once' do
            token.reload.devices.should == list
          end
        end
      end
    end
  end
end