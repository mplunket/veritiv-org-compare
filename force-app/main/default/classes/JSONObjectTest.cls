@isTest
public class JSONObjectTest {

    /* **************************
     * TEST Methods to achieve required code coverage
     *   many of these could be improved by using assert() instead of debug()
     */
    public static  testmethod void test_tokener_nl() {
        //add a new line by inserting /n
        JsonObject.JsonTokener tkr = new  JsonObject.JsonTokener(
        'quoted string foo"');
        system.debug( 'next string is >'+tkr.nextString('"') );
    }
    
    public static  testmethod void test_tokener() {
        JsonObject.JsonTokener tkr = new  JsonObject.JsonTokener('//ff \n{}');
        tkr.nextClean();
        tkr = new  JsonObject.JsonTokener('/*fff*/\n{}');
        tkr.nextClean();
        tkr = new  JsonObject.JsonTokener('#ff*\n{}');
        tkr.nextClean();
        tkr = new  JsonObject.JsonTokener('/**ff \n{}');
        try { tkr.nextClean(); } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Unclosed comment');
        }
    }
    public static  testmethod void test_parsing() {     JSONObject jj; JsonObject.JsonTokener tkr;
        string simple = '{"translatedText":  "Ciao mondo"  }';
        string bool_simple = '{"responseBoolean"  :   true }';
        string nsimple = '{"responseData"  :   {"translatedText":  "Ciao mondo"  }, "responseDetails": null, "responseStatus": 200 }';

        // three methods of constructing an object
        system.debug( jsonobject.instance( bool_simple   ) );
        system.debug( new jsonobject(   bool_simple ) );
        system.debug( new JSONObject( new  JsonObject.JsonTokener(simple) ) );

        tkr = new  JsonObject.JsonTokener(nsimple);
        system.debug( tkr.more() );
        system.debug( tkr.next(1) );
        system.assert( tkr.next(0) == '' );

        try { tkr.next(10000);  } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Ending position out of bounds: 10002');
        }

        system.debug( tkr.next('r') );

        try { tkr.next('z'); } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Expected z and instead saw e');
        }

        system.debug( tkr.nextTo('e') );
        system.debug( tkr.skipTo('p') );
        system.debug( tkr.skipTo('z') );

        tkr = new  JsonObject.JsonTokener(nsimple);
        jj = new JSONObject( tkr);

        system.debug( jj.data );
        system.debug( jj.data.keySet() );

        system.debug( 'response status ' + jj.data.get('responseStatus') );
        system.debug( 'response status ' + jj.get('responseStatus') );
        system.debug( 'response details ' + jj.get('responseDetails') );

        system.debug( jj.getString('responseDetails') );
        system.assert( jj.getString('responseDetails') == null ,'expected null ');

        system.debug('value '+ jj.getValue('responseData') );

        JsonObject.value v = jj.data.get('responseData');
        system.debug( jj.getString('responseDetails') );
        system.debug( 'response data is '+ v.obj);

        //system.assert( v.obj.valu != null);
        system.debug( jj.data.keySet() );


        nsimple = '{"responseString"  :   "foo" }';
        tkr = new  JsonObject.JsonTokener(nsimple);
        jj = new JSONObject( tkr);
        system.debug( jj.get('responseString') );

        nsimple = '{"responseBoolean"  :   true }';
        tkr = new  JsonObject.JsonTokener(nsimple);
        jj = new JSONObject( tkr);
        system.debug( jj.getValue('responseBoolean') );
        system.debug( jj.optBoolean('responseBoolean') );


        try {
        system.debug ( new JSONObject ( new JsonObject.JSONTokener( 'sdfsdf' ) ) );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'A JSONObject text must begin with {');
        }

        try {
        system.debug ( new JSONObject ( new JsonObject.JSONTokener( '{"sdfsdf": true' ) ) );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Expected a , or }');
        }

        try {
        system.debug ( new JSONObject ( new JsonObject.JSONTokener( '{"sdfsdf' ) ) );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Unterminated string');
        }

        try {
        system.debug ( new JSONObject ( new JsonObject.JSONTokener( '{"sdfsdf": 0x009.9 }' ) ) );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Invalid integer: 009.9');
        }


        system.assert ( new JSONObject ( new JsonObject.JSONTokener( '{"sdfsdf": 009 }' ) ).getValue('sdfsdf').num == 9 );

        system.debug ( new JSONObject ( new JsonObject.JSONTokener( '{"foo": 009 }' ) ).get('foo') == 9 );

        // array testing
        system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '[1,2,3]' ) )  );
        system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '[1,2,3,]' ) )  );
        system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '[]' ) )  );
        system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '(1,2,3 )' ) )  );

        try {
        system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '(1,2,3 ]' ) )  );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'Expected a >)<');
        }

        try {
        system.debug ( JSONObject.jsonarray ( new JsonObject.JSONTokener( '1,2,3 ]' ) )  );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'A JSONArray text must start with [');
        }

        try {
            system.debug ( jj.get('notfound')  );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'JSONObject[notfound] not found.');
        }

        system.assert( jj.keys() != null );
        system.assert( jj.length() > 0 );
        system.assert( jj.opt('responseBoolean') != null );
        system.assert( jj.has( 'responseBoolean') );
        try {
            system.debug ( jj.getBoolean('notfound')  );
        } catch(exception ex) {
            system.debug( ' expected >'+ex.getMessage() + '<' );
            system.assert( ex.getMessage() == 'JSONObject[notfound] not found.');
        }
    }

    public static  testmethod void test_valueToString() {
        JsonObject json = new JsonObject();
        json.putOpt('foo', new JSONObject.value('bar'));
        /*
        Make sure that the JSON rendered by this class passes validation by parsers
        from http://json.org/json2.js and http://www.jsonlint.com.
        For example:    {foo: "bar"} is invalid
                        {"foo": "bar"} is valid
        */
        system.assertEquals( '{"foo": "bar"}', json.ValuetoString());
    }

    // test that we can parse json containing a dobule
    public static  testmethod void test_geocode() {
        string simple = '{ "Point": { "coordinates": [ -122.0841430, 37.4219720, 0 ] } }';
        JSONObject jj =  new JSONObject( new  JsonObject.JsonTokener(simple) ) ;
        JsonObject.value p = jj.getValue('Point');
        system.debug (p.obj.data.get('coordinates'));
        JsonObject.value[] vals = p.obj.data.get('coordinates').values;
        system.debug( vals[0].dnum);
        system.assertEquals(3,vals.size());
        system.assertEquals(-122.0841430,   vals[0].dnum);
        system.assertEquals(37.4219720,     vals[1].dnum);
        system.assertEquals('0',            vals[2].valueToString());
    }
    public static  testmethod void test_g(){
        string googlejson = '{  "name": "1600 Amphitheatre Parkway, Mountain View, CA",  "Status": {    "code": 200,    "request": "geocode"  },  "Placemark": [ {    "id": "p1",    "address": "1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA",    "AddressDetails": {   "Accuracy" : 8,   "Country" : {      "AdministrativeArea" : {         "AdministrativeAreaName" : "CA",         "SubAdministrativeArea" : {            "Locality" : {               "LocalityName" : "Mountain View",               "PostalCode" : {                  "PostalCodeNumber" : "94043"               },               "Thoroughfare" : {                  "ThoroughfareName" : "1600 Amphitheatre Pkwy"               }            },         '+
        '   "SubAdministrativeAreaName" : "Santa Clara"         }      },      "CountryName" : "USA",      "CountryNameCode" : "US"   }},    "ExtendedData": {      "LatLonBox": {        "north": 37.4251466,        "south": 37.4188514,        "east": -122.0811574,        "west": -122.0874526      }    },    "Point": {      "coordinates": [ -122.0843700, 37.4217590, 0 ]    }  } ]}   ';
        JSONObject jj = new JSONObject( new JsonObject.JsonTokener(googlejson)  );
        system.assertNotEquals(null,jj);
    }
}