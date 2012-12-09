package Offline;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.RandomAccessFile;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Random;

class SampleSizeCalculatorMutliTables {

	public static int calculateVCDimension(int columns, int booleans) {
		if (columns == 1) {
			return 2 * booleans;
		} else {
			if (booleans == 1)
				return columns + 1;
			else {
				return (int) Math.floor((2 * (columns + 1) * booleans * (Math
						.log((columns + 1) * booleans) / Math.log(2))));
			}
		}
	}
	
	public static int calculateSampleSizeInner(double eps, double delta, int vcd) {
		return (int) Math.ceil(0.5 / (eps * eps) * (vcd + Math.log(1 / delta)));
	}

	public static int calculateSampleSize(int columns, int booleans,double eps, double delta){
		int vcd = SampleSizeCalculatorMutliTables.calculateVCDimension(columns, booleans);
		int size = SampleSizeCalculatorMutliTables.calculateSampleSizeInner(eps, delta, vcd);
		return size;
	}
		
}

public class DatabaseSamplerMultiTables {
	public static int DBSize = OriginalMultiTableDataGenerator.databaseSize;

	// only sql for temp sample table ( not joined yet )

	public static int sampleSqlSentence(int sample_size,
			String inputSqlFileName, String outputSqlFileName,
			String tempSampleTableName) throws IOException {

		int db_size = DatabaseSamplerMultiTables.DBSize;
		RandomAccessFile in;
		BufferedWriter out;
		String tuple;
		Random rand;

		in = new RandomAccessFile(new File(inputSqlFileName), "r");
		File outputfile = new File(outputSqlFileName);
		if (outputfile.exists())
			outputfile.delete();
		out = new BufferedWriter(new FileWriter(outputSqlFileName));
		int rows_sampled[];
		rows_sampled = new int[db_size];
		for (int i = 0; i < db_size; i++)
			rows_sampled[i] = 0;

		int random_tuple;
		String sampleSqlString = "INSERT INTO " + tempSampleTableName + " ";
		rand = new Random();
		// randomly sample s tuples
		for (int i = 0; i < sample_size; i++) {
			int ok = 0;
			while(ok == 0){
				random_tuple = rand.nextInt(db_size);
				//rows_sampled[random_tuple]++;
				if(rows_sampled[random_tuple] == 0){
					ok = 1;
					rows_sampled[random_tuple] = 1;
				}
			}
		}

		int firstTime = 0;
		int startDataIndex = 0;
		for (int i = 0; i < db_size; i++) {
			tuple = in.readLine();
			if (firstTime == 0) {
				// get the index starting for the value
				for (int j = 0; j < tuple.length(); j++) {
					if (tuple.charAt(j) == '('){
						startDataIndex = j;
						break;
					}
				}
				firstTime = 1;
			}
			if (tuple == null)
				break;

			for (int j = 0; j < rows_sampled[i]; j++) {
				String to_wirte = sampleSqlString
						+ tuple.substring(startDataIndex);
				out.write(to_wirte + "\n");
			}
		}

		out.close();
		return sample_size;

	}

	public static int createSampleTableA(Connection conn, String sqlFile,
			String sampleTableName) throws SQLException, IOException {
		Statement st = conn.createStatement();
		String dropQuery = "DROP TABLE IF EXISTS " + sampleTableName + ";";
		st.executeUpdate(dropQuery);
		String deleteAllQuery = "DELETE FROM at;";
		st.executeUpdate(deleteAllQuery);
		// first fillin all rows in at
		String insertString;
		int batchlimit = 1000;
		int lineCounter = 0;
		FileInputStream fstream = new FileInputStream(sqlFile);
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		while ((insertString = br.readLine()) != null) {
			st.executeUpdate(insertString);
//			st.addBatch(insertString);
//			if (lineCounter % batchlimit == 0) {
//				st.executeBatch();
//				st.clearBatch();
//			}
//			lineCounter++;
		}
//		st.executeBatch();
///		st.clearBatch();

		// create a sample joined table!
		String createQuery;
		createQuery = "CREATE TABLE "
				+ sampleTableName
				+ " as ("
				+ "select at.*, b.bv, b.ci, c.cv from at,b,c where at.bi = b.bi and b.ci = c.ci);";
		st.executeUpdate(createQuery);
		st.close();
		return 0;
	}

	public static int createSampleTableB(Connection conn, String sqlFile,
			String sampleTableName) throws SQLException, IOException {

		Statement st = conn.createStatement();
		String dropQuery = "DROP TABLE IF EXISTS " + sampleTableName + ";";
		st.executeUpdate(dropQuery);
		String deleteAllQuery = "DELETE FROM bt;";
		st.executeUpdate(deleteAllQuery);
		// first fillin all rows in at
		String insertString;
		int batchlimit = 1000;
		int lineCounter = 0;
		FileInputStream fstream = new FileInputStream(sqlFile);
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		while ((insertString = br.readLine()) != null) {

			st.addBatch(insertString);
			if (lineCounter % batchlimit == 0) {
				st.executeBatch();
				st.clearBatch();
			}
			lineCounter++;
		}
		st.executeBatch();
		st.clearBatch();

		// create a sample joined table!
		String createQuery;
		createQuery = "CREATE TABLE " + sampleTableName + " as ("
				+ "select bt.*, c.cv from bt,c where bt.ci = c.ci);";
		st.executeUpdate(createQuery);
		st.close();
		return 0;
	}

	public static int createSampleTableC(Connection conn, String sqlFile,
			String sampleTableName) throws SQLException, IOException {

		Statement st = conn.createStatement();
		String dropQuery = "DROP TABLE IF EXISTS " + sampleTableName + ";";
		st.executeUpdate(dropQuery);
		String deleteAllQuery = "DELETE FROM ct;";
		st.executeUpdate(deleteAllQuery);
		// first fillin all rows in at
		String insertString;
		int batchlimit = 1000;
		int lineCounter = 0;
		FileInputStream fstream = new FileInputStream(sqlFile);
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		while ((insertString = br.readLine()) != null) {

			st.addBatch(insertString);
			if (lineCounter % batchlimit == 0) {
				st.executeBatch();
				st.clearBatch();
			}
			lineCounter++;
		}
		st.executeBatch();
		st.clearBatch();

		// create a sample joined table!
		String createQuery;
		createQuery = "CREATE TABLE " + sampleTableName + " as ("
				+ "select ct.* from ct);";
		st.executeUpdate(createQuery);
		st.close();
		return 0;

	}
}
