/**
* Used to read a delimited file.
*/
public class BW_CSVParser {
    private String delim = ',';
// the input data
    private String[] buffer;

    public BW_CSVParser(String data)
    {
        Integer num = data.countMatches('\n');
        this.buffer = new List<String>();
        Integer numcuts = (num / 250) + 1;
        Integer currentCut = 0;
        Integer cutLength = data.length() / numcuts;
        for(Integer i=0;i<numcuts;i++)
        {
            Integer nextLineBreak = data.indexOf('\n',  currentCut + cutLength);
            if(nextLineBreak == -1)
            {
                nextLineBreak = data.length();
            }
            this.buffer.addAll(data.substring(currentcut, nextLineBreak).split('\n'));
            currentCut = nextLineBreak + 1;
        }
    }

    public BW_CSVParser(String data, String delim)
    {
        this.buffer = data.split('\n');
        this.delim = delim;
    }

    /**
    * Read and parse next available line. Return null if end of stream.
    */
    public String[] readLine()
    {
        if(buffer.size() == 0)
            return null;
        String line = this.buffer.remove(0);
        String[] parts = new String[] {};
        while(line != '')
        {
            Integer next = 0;
            if(line.startsWith('"'))
            {
                line = line.substring(1); // strip initial
                Integer quoteIndex = findQuote(line, 0);
                while(quoteIndex == -1)
                {
                    if(buffer.size() == 0)
                    {
                        // EOT!
                        quoteIndex = line.length();
                    } else {
                        // grab the next line
                        line += '\n' + this.buffer.remove(0);
                        quoteIndex = findQuote(line, 0);
                    }
                }
                // advance to comma
                next = quoteIndex + 1;
                parts.add(line.substring(0, quoteIndex).replace('""', '"'));
            } else {
                next = line.indexOf(this.delim, next);
                if(next == -1)
                    next = line.length();
                // NB in Substring, "endindex" is the index of the character AFTER the last index to get
                parts.add(line.substring(0, next));
            }
            if(next == line.length() - 1)
                // case of a terminating comma.
                parts.add('');
            line = next < line.length() ? line.substring(next+1) : '';
        }
        if(parts.size() == 0)
            // empty string - we still want to return something...
            parts.add('');
        return parts;
    }

    static private Pattern quotePattern = Pattern.compile('(?<!")"(?!")');
    /**
    * Find next quote in the line
    */
    public static Integer findQuote(String str, Integer i) {
        if (str == '' || str == null) 
            return -1;
        else if (str.substring(0,1)=='"') {
            if (str.length() == 1 || str.substring(1,2) != '"') 
                return i;
            else 
                return findQuote(str.substring(2), i+2);
        } else {
            return findQuote(str.substring(1), i+1);        
        }
    }
}