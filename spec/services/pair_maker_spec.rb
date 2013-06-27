require 'spec_helper'

describe PairMaker do

  describe '.initialize' do

    context 'when odd number of users' do
      it 'raises an error' do
        expect {
          PairMaker.new '1' => [2, 3, 4], '2' => [3, 1], '3' => [1, 2, 4], '4' => [1, 2, 3]
        }.to raise_error
      end
    end

    context "when one array doesn't have the right size" do
      it 'raises an error' do
        expect {
          PairMaker.new '1' => [2, 3], '2' => [3, 1], '3' => [1, 2]
        }.to raise_error
      end
    end

  end

end
