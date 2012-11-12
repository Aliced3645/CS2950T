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
import java.sql.*;
import java.util.Properties;
import java.util.Random;

//RUN ME TO CREATE BIG DATA!!

class OriginalDataGenerator{
	
	final static public int databaseSize = 1000000;
	final static public int maxValue = 10000;
	final static public int minValue = 0;
	
	public static int generateRandomDataset(Connection conn, String filename) throws SQLException, ClassNotFoundException, IOException{
		
		//the statement should be connected to the databse
		Statement st = conn.createStatement();
		//test if there exists a table called bigdata, if yes, then delete it..
		String dropQuery = "DROP TABLE IF EXISTS bigdata ;";
		st.executeUpdate(dropQuery);
		//create a table
		String createQuery;
		createQuery = "CREATE TABLE bigdata (value integer) ;";
		//generate random data and insert 
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
		return 0;
	}
	
	public static int sqlGenerator(String filename) throws IOException{
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
		Random r = new Random(System.currentTimeMillis()) ;
		for(int i = 0; i < databaseSize; i++){
			int to_insert = r.nextInt(maxValue);
			insertString = "INSERT INTO bigdata VALUES ("+ to_insert + ");";
			bw.write(insertString);
			bw.newLine();
		}
		
		bw.close();
		System.out.println("Create File Down");
		
		return 0;
	}
}


public class OfflineDriver {

	//fell free to modify that.
	public static String dbName = "db.cs.brown.edu/squeezedb";
	public static String userName = "szhang";
	public static String password = "come on baby hey we go";
	
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
		
		// TODO Auto-generated method stub
		Connection conn = OfflineDriver.connectToOriginalDB();
		/* already generated in this machine..... */
		OriginalDataGenerator.sqlGenerator("OriginalSqlQuery");
		OriginalDataGenerator.generateRandomDataset(conn, "OriginalSqlQuery");
		
		
		//sampling
		
		int sampleSize = DatabaseSampler.sampleSqlSentence(10, 10, 0.5, 0.5, "OriginalSqlQuery", "SampledSqlQuery", "sampledata");
		System.out.println("Calculated Sample ize:" + sampleSize);
		
		DatabaseSampler.createSampleTable(conn, "SampledSqlQuery", "sampledata");
		conn.close();
	
	}

}
