/**
 * @description       :
 * @author            : Abhishek
 * @group             : RafterOne
 * @last modified on  : 01-30-2023
 * @last modified by  : Abhishek
 * Modifications Log
 * Ver   Date         Author     Modification
 * 1.0   01-20-2023   Abhishek   Initial Version
**/
public with sharing class MigrationConstant {

    public static final String COLUMN_DELIMITER = 'COMMA';
	public static final String COLUMN_DELIMITER_CHAR = ',';

    public static final Integer HTTP_DEFAULT_TIMEOUT = 120000;
    public static final String HTTP_BASE_URL = '/services/data/v56.0';


    public static final String HTTP_HEADER_CONTENT_TYPE_JSON = 'application/json';
    public static final String HTTP_HEADER_CONTENT_TYPE_CSV = 'text/csv';
    public static final String HTTP_HEADER_CONTENT_TYPE = 'content-type';

    public static final Integer QUEUEABLE_DEPLAY = 1;

    public static final String USER_EMAIL_INVALID = '.invalid';
    public static final String USER_USERNAME_INVALID = '';

}