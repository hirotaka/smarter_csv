require 'spec_helper'

fixture_path = 'spec/fixtures'

describe 'fulfills RFC-4180' do
  let(:options) { {col_sep: ',', row_sep: $INPUT_RECORD_SEPARATOR, quote_char: '"' } }

  context 'separates simple CSV' do
    it 'separating on col_sep' do
      line = 'aaa,bbb,ccc'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [%w[aaa bbb ccc], 3]
    end

    it 'with extra col_sep' do
      line = 'aaa,bbb,ccc,'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [%w[aaa bbb ccc], 3]
    end

    it 'with multiple extra col_sep' do
      line = 'aaa,bbb,ccc,,,'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [%w[aaa bbb ccc], 3]
    end

    it 'preserves whitespace' do
      line = ' aaa , bbb , ccc '
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        [' aaa ', ' bbb ', ' ccc '], 3
      ]
    end
  end

  context 'quoted CSV' do
    it 'separating on col_sep' do
      line = '"aaa","bbb","ccc"'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [%w[aaa bbb ccc], 3]
    end

    it 'with extra col_sep, without given header_size' do
      line = '"aaa","bbb","ccc",'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        ['aaa', 'bbb', 'ccc', ''], 4
      ]
    end

    it 'with extra col_sep, with given header_size' do
      line = '"aaa","bbb","ccc",'
      expect( SmarterCSV.send(:split_line, line, options, 3)).to eq [%w[aaa bbb ccc], 3]
    end

    it 'with multiple extra col_sep, without given header_size' do
      line = '"aaa","bbb","ccc",,,'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        ['aaa', 'bbb', 'ccc', '', '', ''], 6
      ]
    end

    it 'with multiple extra col_sep, with given header_size' do
      line = '"aaa","bbb","ccc",,,'
      expect( SmarterCSV.send(:split_line, line, options, 3)).to eq [%w[aaa bbb ccc], 3]
    end

    it 'quoted parts can contain spaces' do
      line = '" aaa1 aaa2 "," bbb1 bbb2 "," ccc1 ccc2 "'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        [' aaa1 aaa2 ', ' bbb1 bbb2 ', ' ccc1 ccc2 '], 3
      ]
    end

    it 'quoted parts can contain row_sep' do
      line = '"aaa1, aaa2","bbb1, bbb2","ccc1, ccc2"'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        ['aaa1, aaa2', 'bbb1, bbb2', 'ccc1, ccc2'], 3
      ]
    end

    it 'quoted parts can contain row_sep' do
      line = '"aaa1, ""aaa2"", aaa3","""bbb1"", bbb2","ccc1, ""ccc2"""'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        ['aaa1, "aaa2", aaa3', '"bbb1", bbb2', 'ccc1, "ccc2"'], 3
      ]
    end

    it 'some fields are quoted' do
      line = '1,"board 4""",12.95'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        ['1', 'board 4"', '12.95'], 3
      ]
    end

    it 'separating on col_sep' do
      line = '"some","thing","""completely"" different"'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        ['some', 'thing', '"completely" different'], 3
      ]
    end

    it 'parses corner case correctly' do
      line = '"Board 4""","$17.40","10000003427"'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        ['Board 4"', '$17.40', '10000003427'], 3
      ]
    end
  end

  # relaxed parsing compared to RFC-4180
  context 'liberal_parsing' do
    it 'parses corner case correctly' do
      line = 'is,this "three, or four",fields'
      expect( SmarterCSV.send(:split_line, line, options)).to eq [
        ['is', 'this "three, or four"', 'fields'], 3
      ]
    end
  end
end
