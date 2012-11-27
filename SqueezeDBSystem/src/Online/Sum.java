package Online;

import ilog.concert.IloException;
import ilog.concert.IloNumExpr;
import ilog.concert.IloNumVar;
import ilog.cplex.IloCplex;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

//to calculate confidence interval of sum

public class Sum {

	// get the estimated sum
	public static long process(ResultSet result, int sample_size, int db_size)
			throws SQLException {

		HashMap<Integer, Integer> frequencies = new HashMap<Integer, Integer>();
		Integer k;
		Integer v;

		long sum = 0;

		while (result.next()) {
			k = new Integer(result.getInt("value"));// sum first column
			if (frequencies.containsKey(k)) {
				v = frequencies.get(k);
				frequencies.put(k, new Integer(++v));
			} else
				frequencies.put(k, new Integer(1));

		}

		Iterator<Map.Entry<Integer, Integer>> it = frequencies.entrySet()
				.iterator();
		while (it.hasNext()) {
			Entry<Integer, Integer> entry = (Entry<Integer, Integer>) it.next();
			sum += entry.getKey() * (entry.getValue() / (double) sample_size)
					* db_size;
		}

		return sum;
	}

	public static double[] calculateSumConfidenceInterval(ResultSet resultSet,
			int sampleSize, int dbSize, double epsilon) {

		// order: solution_min, solution_max ( confidence bounds )
		double[] bounds = new double[2];
		CplexSolution solution_min;
		CplexSolution solution_max;

		HashMap<Integer, Integer> frequencies = new HashMap<Integer, Integer>();
		double[] selectivity;

		double eta = (double) dbSize / ((double) sampleSize);
		double query_selectivity = 0;

		Integer k;
		Integer v;

		int min = 10000, max = 0;

		try {
			while (resultSet.next()) {
				k = new Integer(resultSet.getInt("value"));

				// update max and min
				if (k.intValue() > max)
					max = k.intValue();
				else if (k.intValue() < min)
					min = k.intValue();

				if (frequencies.containsKey(k)) // already in the list
				{
					v = frequencies.get(k);
					v += 1;

					frequencies.put(k, new Integer(v));
				} else {
					frequencies.put(k, new Integer(1));
				}
			}

			// calculate selectivity: the percentage of a value appears in the
			// sampled dataset
			selectivity = new double[max - min + 1];

			for (int i = min, index = 0; i <= max; i++, index++) {
				v = frequencies.get(new Integer(i));

				if (v != null) {
					selectivity[index] = v.intValue() / ((double) sampleSize);
				} else {
					selectivity[index] = 0;
				}
			}
			// get query selectivity ( sum of selectivity)
			for (int i = 0; i < (max - min + 1); i++) {
				query_selectivity += selectivity[i];
			}

			// min bound
			solution_min = SumSolver.sumSolver(min, max, query_selectivity,
					selectivity, eta, epsilon, false);
			// max bound
			solution_max = SumSolver.sumSolver(min, max, query_selectivity,
					selectivity, eta, epsilon, true);

			bounds[0] = solution_min.objective_value * dbSize;
			bounds[1] = solution_max.objective_value * dbSize;

		} catch (Exception e) {
			e.printStackTrace(System.out);
			// System.out.println(e.getMessage());
		}

		return bounds;

	}

}
