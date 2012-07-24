# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class DummyRenderer < Crumby::Renderer::Haml
end

class DummyModelName
  def human
    "dummy human name"
  end
end

class DummyModel
  def model_name
    DummyModelName.new
  end
end

describe Crumby::Breadcrumbs do
  let(:breadcrumbs) { Crumby::Breadcrumbs.new }

  describe "#add 10 breadcrumbs" do
    before :each do
      10.times { subject.add :many }
    end

    its(:count) {should eq 10}

    it "each breadcrumb should have the correct position" do
      10.times do |position|
        subject.items[position].position.should eq position
      end
    end
  end

  describe "#add one breadcrumb" do

    context "without an argument" do
      it "should get an ArgumentError" do
        expect { subject.add }.to raise_error(ArgumentError)
      end
    end

    context "with one argument" do
      subject { breadcrumbs.add first_argument }

      context "that is a string" do
        let(:first_argument) { "example string" }
        its(:label) { should equal first_argument }
        its(:route) { should be_nil }
      end

      context "that is a symbol" do
        let(:first_argument) { :example_symbol }
        its(:label) { should eq first_argument.to_s.humanize }
        its(:route) { should equal first_argument }
      end

      context "that is an object with model_name method" do
        let(:first_argument) { DummyModel.new }
        its(:label) { should eq first_argument.model_name.human }
        its(:route) { should equal first_argument }
      end

      context "that is an array of objects" do
        context "last is an object with model_name method" do
          let(:first_argument) { [:admin, DummyModel.new] }
          its(:label) { should eq first_argument.last.model_name.human }
          its(:route) { should equal first_argument }
        end

        context "last is a string" do
          let(:first_argument) { [:admin, "other string"] }
          its(:label) { should eq first_argument.last.to_s.humanize }
          its(:route) { should equal first_argument }
        end

      end

      context "that any other type" do
        let(:first_argument) { 5.5 }
        its(:label) { should eq first_argument.to_s.humanize }
        its(:route) { should be_nil }
      end

    end

    context "with label and route argument" do
      let(:label) { "Name" }
      let(:route) { :route }

      subject { breadcrumbs.add(label, route) }

      its(:label) { should equal label }
      its(:route) { should equal route }
    end

    context "with options" do
      let(:options) { { option1: true, option2: false, string: "Text" } }
      subject { breadcrumbs.add(:test, options) }
      its(:options) { should equal options }
    end
  end

  describe "#items" do
    subject { breadcrumbs.items }

    it { should be_an Array }

    context "have no item" do
      its(:count) { should be_zero }
    end

    context "have on item" do
      subject { breadcrumbs.add :test }
      its(:count) { should_not be_zero }
    end
  end

  describe '#renderer' do

    subject { breadcrumbs }

    context "without an arguments" do
      it "should return default renderer" do
        Crumby::Renderer.default_renderer.should_receive(:new).with(subject)
        subject.send(:renderer)
      end
    end

    context "with a DummyRenderer renderer" do
      let(:renderer) { DummyRenderer }
      it "should return the DummyRenderer renderer" do
        renderer.should_receive(:new).with(subject)
        subject.send(:renderer, renderer)
      end
    end

    context "with a String" do
      let(:renderer) { "String" }
      it "raise an argument Error" do
        expect { subject.send(:renderer, renderer) }.to raise_error(ArgumentError)
      end
    end

    context "with an renderer class" do
    end
  end

  describe "#render" do
    subject { breadcrumbs }

    let(:rendered) { stub :rendered }
    let(:renderer) { stub :renderer }

    before :each do
      renderer.should_receive(:render).with(kind_of(Hash)).and_return(rendered)
    end

    context "without any arguments" do
      it "should call renderer with nil and return rendered" do
        subject.should_receive(:renderer).with(nil).and_return(renderer)
        subject.render.should eq rendered
      end
    end

    context "with custom renderer" do
      it "should call renderer with custom renderer and return rendered" do
        subject.should_receive(:renderer).with(renderer).and_return(renderer)
        subject.render(renderer: renderer).should eq rendered
      end
    end

  end


end
