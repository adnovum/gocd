#
# Copyright 2019 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'rails_helper'


describe "admin/tasks/ant/new.html.erb" do
  include GoUtil
  include TaskMother
  include FormUI
  include Admin::TaskHelper

  before :each do
    assign(:cruise_config, config = BasicCruiseConfig.new)
    set(config, "md5", "abcd1234")
    assign(:on_cancel_task_vms, @vms =  java.util.Arrays.asList([vm_for(exec_task('rm')), vm_for(ant_task), vm_for(nant_task), vm_for(rake_task), vm_for(fetch_task_with_exec_on_cancel_task)].to_java(TaskViewModel)))
    allow(view).to receive(:admin_task_create_path).and_return("task_create_path")
    allow(view).to receive(:admin_task_update_path).and_return("task_update_path")
  end

  it "should render a simple ant task for new" do
    task = AntTask.new
    assign(:task, task)
    assign(:task_view_model, Spring.bean("taskViewService").getViewModel(task, 'new'))

    render :template => "admin/tasks/plugin/new.html.erb"

    expect(response.body).to have_selector("form[action='task_create_path']")

    Capybara.string(response.body).find('form').tap do |form|
      form.all("div.fieldset").tap do |divs|
        expect(divs[0]).to have_selector("label", :text => "Build file")
        expect(divs[0]).to have_selector("input[name='task[buildFile]']")
        expect(divs[0]).to have_selector("label", :text => "Target")
        expect(divs[0]).to have_selector("input[name='task[target]']")
        expect(divs[0]).to have_selector("label", :text => "Working directory")
        expect(divs[0]).to have_selector("input[name='task[workingDirectory]']")
      end
    end
  end

  it "should render a simple ant task for edit" do
    task = AntTask.new
    task.setBuildFile("build.xml")
    task.setWorkingDirectory("blah/foo-bar")
    task.setTarget("compile test and just deploy")
    assign(:task, task)
    assign(:task_view_model, Spring.bean("taskViewService").getViewModel(task, 'edit'))

    render :template => "admin/tasks/plugin/edit.html.erb"

    expect(response.body).to have_selector("form[action='task_update_path']")

    Capybara.string(response.body).find('form').tap do |form|
      form.all("div.fieldset").tap do |divs|
        expect(divs[0]).to have_selector("label", :text => "Build file")
        expect(divs[0]).to have_selector("input[name='task[buildFile]'][value='#{task.getBuildFile()}']")
        expect(divs[0]).to have_selector("label", :text => "Target")
        expect(divs[0]).to have_selector("input[name='task[target]'][value='#{task.getTarget()}']")
        expect(divs[0]).to have_selector("label", :text => "Working directory")
        expect(divs[0]).to have_selector("input[name='task[workingDirectory]'][value='#{task.workingDirectory()}']")
      end
    end
  end

  it "should render error messages if errors are present on the config" do
    task = ant_task
    task.addError(com.thoughtworks.go.config.BuildTask::WORKING_DIRECTORY, "working directory error")
    assign(:task, task)
    assign(:task_view_model, Spring.bean("taskViewService").getViewModel(task, 'edit'))

    render :template => "admin/tasks/plugin/edit.html.erb"

    expect(response.body).to have_selector("form[action='task_update_path']")

    Capybara.string(response.body).find('form').tap do |form|
      form.all("div.fieldset").tap do |divs|
        expect(divs[0]).to have_selector("label", :text => "Build file")
        expect(divs[0]).to have_selector("input[name='task[buildFile]'][value='#{task.getBuildFile()}']")
        expect(divs[0]).to have_selector("label", :text => "Target")
        expect(divs[0]).to have_selector("input[name='task[target]'][value='#{task.getTarget()}']")
        expect(divs[0]).to have_selector("label", :text => "Working directory")
        expect(divs[0]).to have_selector("input[name='task[workingDirectory]'][value='#{task.workingDirectory()}']")
        expect(divs[0]).to have_selector("div.field_with_errors input[type='text'][name='task[workingDirectory]']")
        expect(divs[0]).to have_selector("div.form_error", :text => "working directory error")
      end
    end
  end

  it "should unhide on cancel ant task for edit" do
    task = AntTask.new
    task.setBuildFile("build.xml")
    task.setWorkingDirectory("blah/foo-bar")
    task.setTarget("compile test and just deploy")
    task.setCancelTask(ant_task())
    assign(:task, task)
    assign(:task_view_model, Spring.bean("taskViewService").getViewModel(task, 'edit'))

    render :template => "admin/tasks/plugin/edit.html.erb"

    expect(response.body).to have_selector("form[action='task_update_path']")

    Capybara.string(response.body).find('form').tap do |form|
      expect(form).to have_selector("option[selected='selected'][value='ant']")
    end
  end
end
