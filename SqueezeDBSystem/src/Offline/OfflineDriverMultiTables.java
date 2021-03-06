package Offline;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.Random;

class OriginalMultiTableDataGenerator{
	final static public int databaseSize = 100000;
	final static public int maxValue = 10000;
	final static public int minValue = 0;
	
	public static int generateRandomDataset(Connection conn, String filename, String tablename) throws SQLException, IOException{
		Statement st = conn.createStatement();
		
		String dropQuery = "DROP TABLE IF EXISTS " + tablename + ";";
		st.executeUpdate(dropQuery);
		String createQuery = null;
		
		if(tablename.equals("a")){ 
			createQuery = "CREATE TABLE a (ai integer NOT NULL PRIMARY KEY, av integer NOT NULL, " +
					"bi integer, FOREIGN KEY(bi) REFERENCES b(bi)) ;";
		}
		else if(tablename.equals("b")){
			createQuery = "CREATE TABLE b (bi integer NOT NULL PRIMARY KEY, bv integer NOT NULL, " +
					"ci integer, FOREIGN KEY(ci) REFERENCES c(ci)) ;";
			
		}
		else if(tablename.equals("c")){
			createQuery = "CREATE TABLE c (ci integer, cv integer, PRIMARY KEY(ci));";
		}
		st.executeUpdate(createQuery);
		
		//also create small temp tables for later join operation..
		if(tablename.equals("a")){ 
			createQuery = "CREATE TABLE at (ai integer NOT NULL PRIMARY KEY, av integer NOT NULL, " +
					"bi integer, FOREIGN KEY(bi) REFERENCES b(bi)) ;";
		}
		else if(tablename.equals("b")){
			createQuery = "CREATE TABLE bt (bi integer NOT NULL PRIMARY KEY, bv integer NOT NULL, " +
					"ci integer, FOREIGN KEY(ci) REFERENCES c(ci)) ;";
			
		}
		else if(tablename.equals("c")){
			createQuery = "CREATE TABLE ct (ci integer, cv integer, PRIMARY KEY(ci));";
		}
		st.executeUpdate(createQuery);
		
		String insertString;
		
		int batchlimit = 10000;
		FileInputStream fstream = new FileInputStream(filename);
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		int lineCounter = 0;
		
		while((insertString = br.readLine()) != null){
			
			st.addBatch(insertString);		
			if(lineCounter % batchlimit == 0){
				st.executeBatch();
				st.clearBatch();
			}
			lineCounter ++;
		}
		
		st.executeBatch();
		st.clearBatch();
		st.close();		
		System.out.println("Create table " + tablename + " done");
		return 0;
		
	}
	
	//C has two columns, ci and cv. Ci is the primary key yeah.
	public static int sqlGeneratorC(String filename) throws IOException{
		File file = new File(filename);
		if(!file.exists()){
			file.createNewFile();
		}
		else{
			file.delete();
			file.createNewFile();
		}
		
		FileWriter fw = new FileWriter(file.getAbsoluteFile());
		BufferedWriter bw = new BufferedWriter(fw);
		String insertString;
		Random r = new Random(System.currentTimeMillis());
		for(int i = 0; i < databaseSize; i++){
			int to_insert = r.nextInt(maxValue);
			insertString = "INSERT INTO c (ci, cv) VALUES (" + i + "," + to_insert + ");";
			bw.write(insertString);
			bw.newLine();
		}
		
		bw.close();
		System.out.println("Create File Done");
		
		return 0;
	}
	
	//B has two columns, bi and bv. Bi is the primary key yeah.
	public static int sqlGeneratorB(String filename) throws IOException{
		File file = new File(filename);
		if(!file.exists()){
			file.createNewFile();
		}
		else{
			file.delete();
			file.createNewFile();
		}
		
		FileWriter fw = new FileWriter(file.getAbsoluteFile());
		BufferedWriter bw = new BufferedWriter(fw);
		String insertString;
		Random r = new Random(System.currentTimeMillis());
		Random ri = new Random(System.currentTimeMillis());
		for(int i = 0; i < databaseSize; i++){
			int to_insert = r.nextInt(maxValue);
			int to_insert_foreign = ri.nextInt(databaseSize);
			insertString = "INSERT INTO b (bi, bv, ci) VALUES (" + i + "," + to_insert + "," + to_insert_foreign + ");";
			bw.write(insertString);
			bw.newLine();
		}
		
		bw.close();
		System.out.println("Create File Done");
		return 0;
	}
	
	//for table A
	public static int sqlGeneratorA(String filename) throws IOException{
		File file = new File(filename);
		if(!file.exists()){
			file.createNewFile();
		}
		else{
			file.delete();
			file.createNewFile();
		}
		
		FileWriter fw = new FileWriter(file.getAbsoluteFile());
		BufferedWriter bw = new BufferedWriter(fw);
		String insertString;
		Random r = new Random(System.currentTimeMillis());
		Random ri = new Random(System.currentTimeMillis());
		for(int i = 0; i < databaseSize; i++){
			int to_insert = r.nextInt(maxValue);
			int to_insert_foreign = ri.nextInt(databaseSize);
			insertString = "INSERT INTO a (ai, av, bi) VALUES (" + i + "," + to_insert + "," + to_insert_foreign + ");";
			bw.write(insertString);
			bw.newLine();
		}
		
		bw.close();
		System.out.println("Create File Done");
		return 0;
	}
	
}
public class OfflineDriverMultiTables {
	public static String dbName = "db.cs.brown.edu/squeezedb";
	public static String userName = "szhang";
	public static String password = "36453645Zs";
	public static int sampleRowNumberLow = 1027;
	public static int sampleRowNumberMid = 2309;
	public static int sampleRowNumberHigh = 9235;
	
	//3 sample table names, for accuracy: low, mid, high
	public static Connection connectToOriginalDB() throws ClassNotFoundException, SQLException{
		Class.forName("org.postgresql.Driver");
		String url = "jdbc:postgresql://" + dbName;
		Properties props = new Properties();
		props.setProperty("user", OfflineDriver.userName);
		props.setProperty("password", OfflineDriver.password);
		Connection conn = DriverManager.getConnection(url,props);
		return conn;
	}
	
	public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException {
		Connection conn = OfflineDriverMultiTables.connectToOriginalDB();
		//generate files
		OriginalMultiTableDataGenerator.sqlGeneratorC("OriginalSqlQueryC");
		OriginalMultiTableDataGenerator.sqlGeneratorB("OriginalSqlQueryB");
		OriginalMultiTableDataGenerator.sqlGeneratorA("OriginalSqlQueryA");
		OriginalMultiTableDataGenerator.generateRandomDataset(conn, "OriginalSqlQueryC", "c");
		OriginalMultiTableDataGenerator.generateRandomDataset(conn, "OriginalSqlQueryB", "b");
		OriginalMultiTableDataGenerator.generateRandomDataset(conn, "OriginalSqlQueryA", "a");
		
		
		//test the new VC-dimension..
		//pass
		
		//sample sentences basing on sample sizes
		//low
		DatabaseSamplerMultiTables.sampleSqlSentence(OfflineDriverMultiTables.sampleRowNumberLow, "OriginalSqlQueryA", "SampledQueryALow", "at");
		DatabaseSamplerMultiTables.createSampleTableA(conn, "SampledQueryALow", "aj_l");
		DatabaseSamplerMultiTables.sampleSqlSentence(OfflineDriverMultiTables.sampleRowNumberLow, "OriginalSqlQueryB", "SampledQueryBLow", "bt");
		DatabaseSamplerMultiTables.createSampleTableB(conn, "SampledQueryBLow", "bj_l");
		DatabaseSamplerMultiTables.sampleSqlSentence(OfflineDriverMultiTables.sampleRowNumberLow, "OriginalSqlQueryC", "SampledQueryCLow", "ct");
		DatabaseSamplerMultiTables.createSampleTableC(conn, "SampledQueryCLow", "cj_l");
		//mid
		DatabaseSamplerMultiTables.sampleSqlSentence(OfflineDriverMultiTables.sampleRowNumberMid, "OriginalSqlQueryA", "SampledQueryAMid", "at");
		DatabaseSamplerMultiTables.createSampleTableA(conn, "SampledQueryAMid", "aj_m");
		DatabaseSamplerMultiTables.sampleSqlSentence(OfflineDriverMultiTables.sampleRowNumberMid, "OriginalSqlQueryB", "SampledQueryBMid", "bt");
		DatabaseSamplerMultiTables.createSampleTableB(conn, "SampledQueryBMid", "bj_m");
		DatabaseSamplerMultiTables.sampleSqlSentence(OfflineDriverMultiTables.sampleRowNumberMid, "OriginalSqlQueryC", "SampledQueryCMid", "ct");
		DatabaseSamplerMultiTables.createSampleTableC(conn, "SampledQueryCMid", "cj_m");
		//high
		DatabaseSamplerMultiTables.sampleSqlSentence(OfflineDriverMultiTables.sampleRowNumberHigh, "OriginalSqlQueryA", "SampledQueryAHigh", "at");
		DatabaseSamplerMultiTables.createSampleTableA(conn, "SampledQueryAHigh", "aj_h");
		DatabaseSamplerMultiTables.sampleSqlSentence(OfflineDriverMultiTables.sampleRowNumberHigh, "OriginalSqlQueryB", "SampledQueryBHigh", "bt");
		DatabaseSamplerMultiTables.createSampleTableB(conn, "SampledQueryBHigh", "bj_h");
		DatabaseSamplerMultiTables.sampleSqlSentence(OfflineDriverMultiTables.sampleRowNumberHigh, "OriginalSqlQueryC", "SampledQueryCHigh", "ct");
		DatabaseSamplerMultiTables.createSampleTableC(conn, "SampledQueryCHigh", "cj_h");
		
		
	}
}
