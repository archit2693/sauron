require 'rails_helper'

RSpec.describe ProfilesController, type: :controller do
  login_user

  before(:each) do
    ContainerHost.create(hostname: 'p-ubuntu-01', ipaddress: '172.16.33.33')
  end

  describe 'POST#create' do
    context 'success', :vcr do
      it 'creates a new profile', :delete_profile_after, profile_name: 'medium' do
        post :create, params: {profile: {name: 'medium', cpu_limit: '1', memory_limit: '100MB', ssh_authorized_keys: ['abc','def']}}

        expect(JSON.parse(response.body)['success']).to eq(true)
        expect(JSON.parse(response.body)['errors']).to eq('')
        expect(response.code).to eq('201')
      end
    end

    context 'failure' do
      it 'should return bad request for invalid profile' do
        post :create, params: {profile: {name: '', cpu_limit: '1', memory_limit: '100MB', ssh_authorized_keys: ['abc','def']}}

        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(JSON.parse(response.body)['errors']).to eq("Name can't be blank")
        expect(response.code).to eq('400')
      end

      it 'should return server error for failed create operation' do
        allow_any_instance_of(Profile).to receive(:create).and_return(false)
        post :create, params: {profile: {name: 'bad-value'}}

        expect(JSON.parse(response.body)['success']).to eq(false)
        expect(response.code).to eq('500')
      end
    end
  end

  describe 'GET#index' do
    context 'success', :vcr do
      it 'should return list of profiles' do
        get :index
        expect(assigns(:profiles)).to eq(['default'])
      end
    end
  end

  describe 'GET#show' do
    context 'success', :vcr do
      it 'should return details of a profile', :delete_profile_after, profile_name: 'new-profile' do
        LxdProfile.create_from(to: 'new-profile', overrides: {ssh_authorized_keys: ['abc','def'], "limits.cpu": '2', "limits.memory": '10GB'})
        get :show, params: {name: 'new-profile'}
        expect(assigns(:profile).name).to eq('new-profile')
        expect(assigns(:profile).cpu_limit).to eq('2')
        expect(assigns(:profile).memory_limit).to eq('10GB')
        expect(assigns(:profile).ssh_authorized_keys).to eq(['abc','def'])
      end
    end
  end
end
