package Online;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

public class Avg {
	public static double process(ResultSet result, int sample_size, int db_size) throws SQLException {

		HashMap<Integer, Integer> frequencies = new HashMap<Integer, Integer>();
		Integer k;
		Integer v;

		double avg = 0;

		while (result.next()) {
			k = new Integer(result.getInt("value"));// sum first column
			if (frequencies.containsKey(k)) {
				v = frequencies.get(k);
				frequencies.put(k, new Integer(++v));
			} else
				frequencies.put(k, new Integer(1));

		}


		Iterator<Map.Entry<Integer, Integer>> it = frequencies.entrySet().iterator();
		while (it.hasNext()) {
			Entry<Integer, Integer> entry = (Entry<Integer, Integer>) it.next();
			avg += entry.getKey() * (entry.getValue() / (double)sample_size);
		}

		return avg;
	}
}
