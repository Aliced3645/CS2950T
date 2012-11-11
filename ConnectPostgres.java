
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


class DataGenerator{
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

public class ConnectPostgres {

	/**
	 * @param args
	 * @throws ClassNotFoundException 
	 * @throws SQLException 
	 * @throws IOException 
	 */
	
	//use the file to generate all data...
	public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException {
		// TODO Auto-generated method stub
		
		Class.forName("org.postgresql.Driver");
		String url = "jdbc:postgresql://db.cs.brown.edu/squeezedb";
		//System.out.println("caoji");
		Properties props = new Properties();
		props.setProperty("user", "szhang");
		props.setProperty("password", "36453645Zs");
		
		Connection conn = DriverManager.getConnection(url,props);
		Statement st = conn.createStatement();
		String query;
		query = "SELECT * FROM people";
		ResultSet rs = st.executeQuery(query);
		while(rs.next()){
			System.out.println(rs.getString(1));
		}
		
		DataGenerator.sqlGenerator("qunzhujijida");
		DataGenerator.generateRandomDataset(conn, "qunzhujijida");
		
		conn.close();
		rs.close();
		st.close();
		
	}

}
