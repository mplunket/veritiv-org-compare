@isTest
private class BW_CSVParserTest {
	
	static testmethod void testSplitCsvSimple(){
		String line = 'abc,efg';
		String[] splitted = new BW_CSVParser(line).readLine();
		System.assertEquals(2, splitted.size());

		System.assertEquals('efg', splitted[1]);
		System.assertEquals('abc', splitted[0]);
	}

	static testmethod void testSplitCsvEOL(){
		String line = 'abc,';
		String[] splitted = new BW_CSVParser(line).readLine();
		System.assertEquals(2, splitted.size());

		System.assertEquals('', splitted[1]);
		System.assertEquals('abc', splitted[0]);
	}

	static testmethod void testSplitCsvQuotedSimple(){
		String line = '"abc,def"';
		String[] splitted = new BW_CSVParser(line).readLine();
		System.assertEquals('abc,def', splitted[0]);
	}

	static testmethod void testSplitCsvQuoted(){
		String line = '"abc,def",gh"i,"jk""l",""';
		String[] splitted = new BW_CSVParser(line).readLine();
		System.assertEquals(4, splitted.size());

		System.assertEquals('gh"i', splitted[1]);
		System.assertEquals('abc,def', splitted[0]);
		System.assertEquals('jk"l', splitted[2]);
		System.assertEquals('', splitted[3]);
	}

	static testmethod void testSplitCsvQuotedWithNewLine(){
		String line = '"abc,def\nBoo\nBoo",Test';
		BW_CSVParser reader = new BW_CSVParser(line);
		String[] splitted = reader.readLine();
		System.assertEquals('abc,def\nBoo\nBoo', splitted[0]);
		System.assertEquals('Test', splitted[1]);
		System.assertEquals(null, reader.readLine());
	}

	static testmethod void testSplitCsvQuotedWithEOT(){
		String line = '"abc,def\nBoo';
		BW_CSVParser reader = new BW_CSVParser(line);
		String[] splitted = reader.readLine();
		System.assertEquals('abc,def\nBoo', splitted[0]);
		System.assertEquals(null, reader.readLine());
	}

	static testmethod void testSplitCsvQuotedWithEscapeQuotes(){
		String line = '"""abc""",d""ef,B\'oo';
		BW_CSVParser reader = new BW_CSVParser(line);
		String[] splitted = reader.readLine();
		System.assertEquals('"abc"', splitted[0]);
		System.assertEquals('d""ef', splitted[1]);
		System.assertEquals('B\'oo', splitted[2]);
	}

	static testmethod void testTabDelim(){
		String line = 'abc\tdef';
		BW_CSVParser reader = new BW_CSVParser(line, '\t');
		String[] splitted = reader.readLine();
		System.assertEquals('abc', splitted[0]);
	}

	static testmethod void testEmptyStrings(){
		String line = ',,,,';
		BW_CSVParser reader = new BW_CSVParser(line);
		String[] splitted = reader.readLine();
		System.assertEquals(5, splitted.size());
		for(String s: splitted){
			System.assertEquals('', s);
		}
	}

	// make sure we still get a result even if the source is empty...
	static testmethod void testEmptyString(){
		String line = '';
		BW_CSVParser reader = new BW_CSVParser(line);
		String[] splitted = reader.readLine();
		System.assertEquals(1, splitted.size());
		System.assertEquals('', splitted[0]);
	}

	
}