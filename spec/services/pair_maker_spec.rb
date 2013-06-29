require 'spec_helper'
require 'ruby-debug'

describe PairMaker do

  let(:pairmaker) { PairMaker.new }

  describe '#get_pairs' do

    subject { pairmaker.get_pairs }

    context "when one team exists" do

      let(:team) { Fabricate :team }

      before :each do
        team.users = users
      end

      context "and there are an even number of people on the team" do

        let(:users) do
          Array.new(4) { Fabricate :user }
        end

        it 'makes 4 pairings' do
          subject
          Pairing.count.should eq(4)
        end

      end

      context "and there is an odd number of people on the team" do
        let(:users) do
          Array.new(3) { Fabricate :user }
        end

        it 'makes 2 pairings' do
          subject
          Pairing.count.should eq(2)
        end

      end

    end

    context "when two teams exist" do

      let(:teams) { Array.new(2) { Fabricate :team } }

      before(:each) do
        teams[0].users = team1_users
        teams[1].users = team2_users
      end

      context "and there's an even number on both teams" do

        let(:team1_users) {
          Array.new(4) { Fabricate :user }
        }
        let(:team2_users) {
          Array.new(6) { Fabricate :user }
        }

        it "creates 10 pairings" do
          subject
          Pairing.count.should eq(10)
        end

        describe "the pairings" do

          it "are of the same team" do
            Pairing.all.each do |p|
              p.user1.teams.should eq(p.user2.teams)
            end
          end

        end

      end

      context "and there's an odd number on both teams" do

        let(:team1_users) {
          Array.new(3) { Fabricate :user }
        }
        let(:team2_users) {
          Array.new(5) { Fabricate :user }
        }

        it "creates 8 pairings" do
          subject
          Pairing.count.should eq(8)
        end

        it "creates a pairing that crosses teams" do
          subject
          Pairing.all.detect{ |p| p.user1.teams != p.user2.teams }.should be
        end

      end

      context "and there's an even number on one team and odd on the other" do
        let(:team1_users) {
          Array.new(3) { Fabricate :user }
        }
        let(:team2_users) {
          Array.new(6) { Fabricate :user }
        }

        it "creates 8 pairings" do
          subject
          Pairing.count.should eq(8)
        end

      end

    end

  end

end
