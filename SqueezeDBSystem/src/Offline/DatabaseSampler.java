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
import java.io.RandomAccessFile;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Random;

import Offline.OfflineDriver;
import Offline.OriginalDataGenerator;

class SampleSizeCalculator {
	// transplant the Matlab Code into Java Code
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

	public static int calculateSampleSize(float eps, float delta, int vcd) {
		return (int) Math.ceil(0.5 / (eps * eps) * (vcd + Math.log(1 / delta)));
	}

}

public class DatabaseSampler {

	public static int DBSize;
	public static int SampleSize;

	public int sampleSqlSentence(int columns, int booleans, float eps, float delta,
			 String inputSqlFileName, String outputSqlFileName) throws IOException {

		int vcDimension = SampleSizeCalculator.calculateVCDimension(columns,
				booleans);
		int sample_size = DatabaseSampler.SampleSize = SampleSizeCalculator
				.calculateSampleSize(eps, delta, vcDimension);
		// uniform Sampling
		int db_size = DatabaseSampler.DBSize = OriginalDataGenerator.databaseSize;

		// Since it takes a long time to connect to DB, so here to use a tricky
		// idea, to
		// load the sql sentences file directly, and randomly select [sample
		// size] lines and
		// generate a new sql sentence file.

		RandomAccessFile in;
		BufferedWriter out;
		String tuple;
		Random rand;

		in = new RandomAccessFile(new File(inputSqlFileName), "r");
		out = new BufferedWriter(new FileWriter(outputSqlFileName));
		int rows_sampled[];
		rows_sampled = new int[db_size];
		for (int i = 0; i < db_size; i++)
			rows_sampled[i] = 0;

		int random_tuple;

		rand = new Random();
		// randomly sample s tuples
		for (int i = 0; i < sample_size; i++) {
			random_tuple = rand.nextInt(db_size);
			rows_sampled[random_tuple]++;
		}

		for (int i = 0; i < db_size; i++) {
			tuple = in.readLine();
			if (tuple == null)
				break;
			for (int j = 0; j < rows_sampled[i]; j++)
				out.write(tuple + "\n");
		}

		out.close();
		return 0;
	}
	
	public int createSampleTable(Connection conn, String sqlFile, String sampleTableName) throws SQLException, IOException{
		
		Statement st = conn.createStatement();
		//test if there exists a table called bigdata, if yes, then delete it..
		String dropQuery = "DROP TABLE IF EXISTS " + sampleTableName  + ";" ;
		st.executeUpdate(dropQuery);
		
		String createQuery;
		createQuery = "CREATE TABLE "+ sampleTableName+ " (value integer) ;";
		st.executeUpdate(createQuery);
		
		String insertString;
		int batchlimit = 1000;
		int lineCounter = 0;
		
		FileInputStream fstream = new FileInputStream(sqlFile);
		DataInputStream in = new DataInputStream(fstream);
		BufferedReader br = new BufferedReader(new InputStreamReader(in));
		
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

}
