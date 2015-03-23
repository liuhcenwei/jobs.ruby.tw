# -*- encoding : utf-8 -*-
require 'spec_helper'

describe JobsController, type: :controller do

  before do
    @user = User.new
    @job = Job.new
    allow(@job).to receive(:to_param).and_return('123')
    allow(controller).to receive(:authenticate_user!)
    allow(controller).to receive(:current_user).and_return(@user)
  end

  let(:current_user) { @user }

  describe 'GET index' do
    it 'should render successful' do
      Job.stub_chain(:online, :recent).and_return([@job])
      get :index

      assigns[:jobs].should eq [@job]
      response.should be_success
    end

    context 'by keyword' do
      it 'should render successful' do
        online_jobs = double('jobs')
        Job.should_receive(:online).and_return(online_jobs)
        online_jobs.should_receive('search').with('rails').and_return([@job])

        get :index, keyword: 'rails'

        assigns[:jobs].should eq [@job]
        response.should be_success
      end
    end

    context 'by user' do
      it 'should render successful' do
        user = double('user')
        User.should_receive(:find).with('99').and_return(user)
        user.stub_chain(:jobs, :recent).and_return([@job])

        get :index, user_id: 99

        assigns[:jobs].should eq [@job]
        response.should be_success
      end
    end
  end

  describe 'GET show' do
    it 'should render successful' do
      Job.should_receive(:find).with('123').and_return(@job)
      get :show, id: 123

      assigns[:job].should eq @job
      response.should be_success
    end
  end

  describe 'GET new' do
    it 'should render successful' do
      Job.should_receive(:new).and_return(@job)
      get :new

      assigns[:job].should eq @job
      response.should be_success
    end
  end

  describe 'POST create' do
    it 'should save successful and redirect to show' do
      current_user.jobs.should_receive(:build).with('title' => 'abc').and_return(@job)
      @job.should_receive(:save).and_return(true)
      post :create, job: { title: 'abc' }

      response.should be_redirect
    end

    it 'should save failed and render new' do
      post :create, job: { titie: '' }

      response.should render_template(:new)
      response.should be_success
    end
  end

  describe 'GET edit' do
    it 'should render successful' do
      current_user.stub_chain(:jobs, :find).with('123').and_return(@job)
      get :edit, id: 123

      assigns[:job].should eq @job
      response.should be_success
    end
  end

  describe 'PUT update' do
    it 'should save successful and redirect to show' do
      current_user.stub_chain(:jobs, :find).with('123').and_return(@job)
      @job.should_receive(:update_attributes).with('title' => 'abc').and_return(true)
      put :update, id: 123, job: { title: 'abc' }

      response.should be_redirect
    end

    it 'should save failed and render new' do
      current_user.stub_chain(:jobs, :find).with('123').and_return(@job)
      put :update, id: 123, job: { title: '' }

      response.should render_template(:edit)
      response.should be_success
    end
  end

  describe 'DELETE destroy' do
    it 'should delete successful' do
      current_user.stub_chain(:jobs, :find).with('123').and_return(@job)
      @job.should_receive(:destroy)
      delete :destroy, id: 123
      response.should be_redirect
    end

  end

  describe 'GET/POST preview' do
    it 'should render successful' do
      current_user.jobs.should_receive(:build).with('title' => 'abc').and_return(@job)
      @job.should_receive(:valid?)

      post :preview, job: { title: 'abc' }

      response.should be_success
    end
  end

  describe 'PUT open' do
    it 'should open job' do
      current_user.stub_chain(:jobs, :find).with('123').and_return(@job)
      @job.should_receive(:open)
      @job.should_receive(:save!)

      put :open, id: 123
      response.should be_redirect
    end
  end

  describe 'PUT close' do
    it 'should open job' do
      current_user.stub_chain(:jobs, :find).with('123').and_return(@job)
      @job.should_receive(:close)
      @job.should_receive(:save!)

      put :close, id: 123
      response.should be_redirect
    end
  end

end
