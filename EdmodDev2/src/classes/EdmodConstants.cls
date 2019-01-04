/*
 * EdmodConstants class define Constants.
 */
public class EdmodConstants {
    public static Integer NO_OF_HEADERS = 37;
    public static String HEADER_ROW = 'Id, First Name, Last Name, Email, Phone, Date Joined, Last Login, Class Code, School, School NCES ID, District, District NCES ID, City, State, Country, Num Sections, Num Students, Num Students Who Completed A Project, Num Student Program Shares, Teacher Checklist Completed 1, Teacher Checklist Completed 2, Teacher Checklist Completed 3, Teacher Checklist Completed 4, Teacher Checklist Completed 5, Students Completed Music 1 Hour, Students Completed Music 10 Hour, Students Completed Art 1 Hour, Students Completed Art 10 Hour, Students Completed Sports 1 Hour, Students Completed Sports 10 Hour, Students Started Music 1 Hour, Students Started Art 1 Hour, Students Started Sports 1 Hour, Students Started Music 10 Hour, Students Started Art 10 Hour, Students Started Sports 10 Hour, Num Students Who Started A Project '; 
    public static String UNIQUE_SIGN_UPS = 'UNIQUE_SIGN_UPS';
    public static String UNIQUE_PROJECT_STARTED = 'UNIQUE_PROJECT_STARTED';
    public static String UNIQUE_PROJECT_COMPLETED = 'UNIQUE_PROJECT_COMPLETED';
    public static String UNIQUE_SHARES = 'UNIQUE_SHARES';
    public static String COMPLETED_MUSIC1H = 'COMPLETED_MUSIC1H';
    public static String COMPLETED_MUSIC10H = 'COMPLETED_MUSIC10H';
    public static String COMPLETED_ART1H = 'COMPLETED_ART1H';
    public static String COMPLETED_ART10H = 'COMPLETED_ART10H';
    public static String COMPLETED_SPORTS1H = 'COMPLETED_SPORTS1H';
    public static String COMPLETED_SPORTS10H = 'COMPLETED_SPORTS10H';
    public static String STARTED_MUSIC1H = 'STARTED_MUSIC1H';
    public static String STARTED_ART1H = 'STARTED_ART1H';
    public static String STARTED_SPORTS1H = 'STARTED_SPORTS1H';
    public static String STARTED_MUSIC10H = 'STARTED_MUSIC10H';
    public static String STARTED_ART10H = 'STARTED_ART10H';
    public static String STARTED_SPORTS10H = 'STARTED_SPORTS10H';
    public static String C1 = 'C1';
    public static String C2 = 'C2';
    public static String C3 = 'C3';
    public static String C4 = 'C4';
    public static String C5 = 'C5';
    public static Integer MINIMUM_METRIC_VALUE = Integer.valueOf('0');
    public static String CSV_LINE_SEPERATOR = '<br>';
    public static String CSV_LINE_SEPERATOR_CSV = '\n';
    public static String CSV_COLUMN_SEPERATOR = ',';
    public static String KEY_DELIMITER = '_';
    public static String SERACH_LIKE = '%';
    public static String NURTURING_OPPORTUNITY = 'NURTURING';
    public static String ONBOARDING_OPPORTUNITY = 'ONBOARDING';
    //Onboarding Stages
    public static String ONBOARDING_STAGE_S1 = 'S1: TEACHER_SIGNED_UP';
    public static String ONBOARDING_STAGE_S2 = 'S2: ATLEAST_ONE_STUDENT_SIGNEDUP';
    public static String ONBOARDING_STAGE_S3 = 'S3: ATLEAST_ONE_STUDENT_STARTED_PROJECT';
    public static String ONBOARDING_STAGE_S4 = 'S4: ATLEAST_ONE_STUDENT_COMPLETED_PROJECT';
    //Nurturing Stages
    public static String NURTURING_STAGE_S1 = 'S1: UPTO_50%_STUDENTS_COMPLETED_PROJECT';
    public static String NURTURING_STAGE_S2 = 'S2: UPTO_75%_STUDENTS_COMPLETED_PROJECT';
    public static String NURTURING_STAGE_S3 = 'S3: UPTO_100%_STUDENTS_COMPLETED_PROJECT';
    public static String NURTURING_STAGE_S4 = 'S4: 100%_STUDENTS_COMPLETED_PROJECT';
    //DML Operations constants
    public static String DML_OPERATION_INSERT = 'Insert';
    public static String DML_OPERATION_UPDATE = 'Update';
    public static String DML_OPERATION_DELETE = 'Delete';
    //Record Types Constant
    public static String RECORD_TYPE_ONBOARDING = 'Onboarding_TS';
    public static String RECORD_TYPE_NURTURING = 'Nurturing_TS';

    public static String TEACHER_REGISTERED = 'TEACHER_REGISTERED';

    //Default Account Values
    public static String DEFAULT_SCHOOL_NAME = 'Facebook EdMod';
    public static String DEFAULT_SCHOOL_STATE = 'FB';
    public static String DEFAULT_SCHOOL_CITY = 'Menlo Park';
    public static String DEFAULT_SCHOOL_COUNTRY = 'US';
    
    //Timeout Constant
    public static Integer REQUEST_TIMEOUT_MS=30000;

    //Minimum No Of Students to create Nurturing Opportunities
    public static Integer MIN_STUDENTS_NURTURING_STAGES=14;

    /*
     * getHeaderToMetricTypeMap
     * @description Returns Header to Metric Type Map
     */
    public static Map < String, String > getHeaderToMetricTypeMap() {
        Map < String, String > getHeaderToMetricTypeMap = new Map < String, String > ();
        getHeaderToMetricTypeMap.put('Num Students', EdmodConstants.UNIQUE_SIGN_UPS);
        getHeaderToMetricTypeMap.put('Num Students Who Completed A Project', EdmodConstants.UNIQUE_PROJECT_COMPLETED);
        getHeaderToMetricTypeMap.put('Num Student Program Shares', EdmodConstants.UNIQUE_SHARES);
        getHeaderToMetricTypeMap.put('Students Completed Music 1 Hour', EdmodConstants.COMPLETED_MUSIC1H);
        getHeaderToMetricTypeMap.put('Students Completed Music 10 Hour', EdmodConstants.COMPLETED_MUSIC10H);
        getHeaderToMetricTypeMap.put('Students Completed Art 1 Hour', EdmodConstants.COMPLETED_ART1H);
        getHeaderToMetricTypeMap.put('Students Completed Art 10 Hour', EdmodConstants.COMPLETED_ART10H);
        getHeaderToMetricTypeMap.put('Students Completed Sports 1 Hour', EdmodConstants.COMPLETED_SPORTS1H);
        getHeaderToMetricTypeMap.put('Students Completed Sports 10 Hour', EdmodConstants.COMPLETED_SPORTS10H);
        getHeaderToMetricTypeMap.put('Students Started Music 1 Hour', EdmodConstants.STARTED_MUSIC1H);
        getHeaderToMetricTypeMap.put('Students Started Art 1 Hour', EdmodConstants.STARTED_ART1H);
        getHeaderToMetricTypeMap.put('Students Started Sports 1 Hour', EdmodConstants.STARTED_SPORTS1H);
        getHeaderToMetricTypeMap.put('Students Started Music 10 Hour', EdmodConstants.STARTED_MUSIC10H);
        getHeaderToMetricTypeMap.put('Students Started Art 10 Hour', EdmodConstants.STARTED_ART10H);
        getHeaderToMetricTypeMap.put('Students Started Sports 10 Hour', EdmodConstants.STARTED_SPORTS10H);
        getHeaderToMetricTypeMap.put('Teacher Checklist Completed 1', EdmodConstants.C1);
        getHeaderToMetricTypeMap.put('Teacher Checklist Completed 2', EdmodConstants.C2);
        getHeaderToMetricTypeMap.put('Teacher Checklist Completed 3', EdmodConstants.C3);
        getHeaderToMetricTypeMap.put('Teacher Checklist Completed 4', EdmodConstants.C4);
        getHeaderToMetricTypeMap.put('Teacher Checklist Completed 5', EdmodConstants.C5);
        getHeaderToMetricTypeMap.put('Num Students Who Started A Project', EdmodConstants.UNIQUE_PROJECT_STARTED);
        return getHeaderToMetricTypeMap;
    }
}