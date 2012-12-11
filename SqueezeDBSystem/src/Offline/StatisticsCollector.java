package Offline;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.TreeMap;

//calculate statistics for data
//and pass the meta data to D3 to visualize
public class StatisticsCollector {
	
	public static HashMap<Integer, Integer> OriginalDatasetFrequency;
	public static HashMap<Integer, Integer> LowSampledDatasetFrequency;
	public static HashMap<Integer, Integer> MidSampledDatasetFrequency;
	public static HashMap<Integer, Integer> HighSampledDatasetFrequency;
	
	//get the value distribution(Frequency..)
	public static Map<Integer, Integer> getFrequency(ResultSet result) throws SQLException{
		
		Map<Integer, Integer> unsortedFrequencies =new HashMap<Integer, Integer>();
		Map<Integer, Integer> frequencies = new TreeMap<Integer, Integer>(unsortedFrequencies);
		
		Integer k;
		Integer v;

		while (result.next()) {
			k = new Integer(result.getInt("av"));// sum first column
			if (frequencies.containsKey(k)) {
				v = frequencies.get(k);
				frequencies.put(k, new Integer(++v));
			} else
				frequencies.put(k, new Integer(1));
		}
		
		return frequencies;
	}
	
	public static void writeHashmapToFile(Map<Integer,Integer> hash, String filename) throws IOException{
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
		
		//iterate the hash and insert to the file
		Iterator it = hash.entrySet().iterator();
		while(it.hasNext()){
			Entry<Integer, Integer> entry = (Entry<Integer, Integer>) it.next();
			String toWrite = entry.getKey().toString() + " " + entry.getValue().toString();
			bw.write(toWrite);
			bw.newLine();
		}
		bw.close();
		return;
		
	}
	
	//calculate the frequencies for D3 visualization and show on the page..
	public static void main(String[] args) throws ClassNotFoundException, SQLException, IOException {
		Connection conn = OfflineDriver.connectToOriginalDB();
		Statement st = conn.createStatement();
		
		String queryO = "SELECT * FROM a";
		ResultSet rsO = st.executeQuery(queryO);
		Map<Integer,Integer> FrequencyO = StatisticsCollector.getFrequency(rsO);
		StatisticsCollector.writeHashmapToFile(FrequencyO, "FreqOA");
		
		String queryL = "SELECT * FROM aj_l";
		ResultSet rsL = st.executeQuery(queryL);
		Map<Integer,Integer> FrequencyL = StatisticsCollector.getFrequency(rsL);
		StatisticsCollector.writeHashmapToFile(FrequencyL, "FreqLowA");
		
		String queryM = "SELECT * FROM aj_m";
		ResultSet rsM = st.executeQuery(queryM);
		Map<Integer,Integer> FrequencyM = StatisticsCollector.getFrequency(rsM);
		StatisticsCollector.writeHashmapToFile(FrequencyM, "FreqMidA");
		
		String queryH = "SELECT * FROM aj_h";
		ResultSet rsH = st.executeQuery(queryH);
		Map<Integer,Integer> FrequencyH = StatisticsCollector.getFrequency(rsH);
		StatisticsCollector.writeHashmapToFile(FrequencyH, "FreqHighA");
		
		st.close();
		rsH.close();
		rsO.close();
		rsM.close();
		rsL.close();
		conn.close();
	
	}
}
