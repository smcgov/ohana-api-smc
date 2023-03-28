require 'rails_helper'

describe LocationFilter do
  describe 'validated_radius' do
    context 'when radius is blank ' do
      it 'returns custom radius' do
        filter = LocationFilter.new(Location)
        result = filter.validated_radius('', 0.5)

        expect(result).to eq 0.5
      end
    end

    context 'when radius is invalid ' do
      it 'raises an exception' do
        filter = LocationFilter.new(Location)
        expect { filter.validated_radius('foo', 0.5) }.to raise_error Exceptions::InvalidRadius
      end
    end

    context 'when radius is greater than 50 ' do
      it 'returns 50' do
        filter = LocationFilter.new(Location)
        result = filter.validated_radius(100, 5)

        expect(result).to eq 50
      end
    end

    context 'when radius is smaller than 0.1 ' do
      it 'returns 0.1' do
        filter = LocationFilter.new(Location)
        result = filter.validated_radius(0.05, 5)

        expect(result).to eq 0.1
      end
    end

    context 'when radius is between 0.1 and 50' do
      it 'returns the radius' do
        filter = LocationFilter.new(Location)
        result = filter.validated_radius(20, 5)

        expect(result).to eq 20
      end
    end
  end
end
