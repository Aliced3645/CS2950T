package Online;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;

public class Variance {
	
	static double term1;
	static double term2;
	
	public static double process(ResultSet result, int sample_size, int db_size)
			throws SQLException {

		double variance = 0;
		double term1,term2;
		long size_minus_1, squaresize_minus_size;
		term1 = term2 = 0.0;
		size_minus_1 = squaresize_minus_size = 0;
		
		HashMap<Integer, Integer> frequencies = new HashMap<Integer, Integer>();
		Integer k;
		Integer v;


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
		while (it.hasNext()){
			  Entry<Integer, Integer> entry = (Entry<Integer, Integer>) it.next();
			  
			  //estimated frequency in original dataset
			  size_minus_1 += entry.getValue()  / (double) sample_size * db_size;  
			    
			  
			  term1 += (entry.getKey() * entry.getKey()) * (entry.getValue() / (double) sample_size) * db_size;
			  
			  term2 += entry.getKey() * (entry.getValue() / (double) sample_size) * db_size;
			  
			}
		
		size_minus_1 -= 1;
		squaresize_minus_size = size_minus_1 * (size_minus_1 + 1);
		
		//variance = term2;
		
		term2 = term2 * term2;
		variance =  term1 / size_minus_1  - term2 / squaresize_minus_size ;
		
		Variance.term1 = term1;
		Variance.term2 = term2;
		return variance;
	}
	
	
	public static double[] calculateVarianceConfidenceInterval(ResultSet resultSet,
			int sampleSize, int dbSize, double epsilon) {

		// order: solution_min, solution_max ( confidence bounds )
		double[] bounds = new double[2];
		
		double[] psi_bounds = new double[2];
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
			solution_min = VarianceSolver.varianceSolver(min, max, query_selectivity,
					selectivity, eta, epsilon, false);
			// max bound
			solution_max = VarianceSolver.varianceSolver(min, max, query_selectivity,
					selectivity, eta, epsilon, true);

			psi_bounds[0] = solution_min.objective_value * dbSize;
			psi_bounds[1] = solution_max.objective_value * dbSize;
			
			double[] sigma_bounds = new double[2];
			solution_min = SumSolver.sumSolver(min, max, query_selectivity,
					selectivity, eta, epsilon, false);
			// max bound
			solution_max = SumSolver.sumSolver(min, max, query_selectivity,
					selectivity, eta, epsilon, true);
			
			sigma_bounds[0] = solution_min.objective_value * dbSize;
			sigma_bounds[1] = solution_max.objective_value * dbSize;
			
			double psi_upper_divisor = dbSize * (query_selectivity - epsilon) - 1;
			double psi_lower_divisor = dbSize * (query_selectivity + epsilon) - 1;

			double sigma_upper_divisor = (dbSize * (query_selectivity + epsilon)) * (dbSize * (query_selectivity + epsilon)) - dbSize * (query_selectivity - epsilon);
			double sigma_lower_divisor = (dbSize * (query_selectivity - epsilon)) * (dbSize * (query_selectivity - epsilon)) - dbSize * (query_selectivity + epsilon);

			double psi_upper = psi_bounds[1] + term1;
			double psi_lower = psi_bounds[0] + term1;

			double squaresigma_upper;
			double squaresigma_lower;
		
			//squaresigma_upper = Math.sqrt(term2);
		    //squaresigma_lower = 0;
			
			term2 = Math.sqrt(term2);
			
			squaresigma_upper = (sigma_bounds[1] + term2) * (sigma_bounds[1] + term2);
		    squaresigma_lower = (sigma_bounds[0] + term2) * (sigma_bounds[0] + term2);
		
			
			if((sigma_bounds[0] + term2)>=0)
			{
			    squaresigma_upper = (sigma_bounds[1] + term2) * (sigma_bounds[1] + term2);
			    squaresigma_lower = (sigma_bounds[0] + term2) * (sigma_bounds[0] + term2);
			}
			else if((sigma_bounds[0] + term2)<0 && (sigma_bounds[1] + term2)>=0)
			{
			    squaresigma_upper = Math.max((sigma_bounds[1] + term2) * (sigma_bounds[1] + term2) , (sigma_bounds[0] + term2) * (sigma_bounds[0] + term2));
			    squaresigma_lower = 0.0;
			}
			else
			{
			    squaresigma_upper = (sigma_bounds[0] + term2) * (sigma_bounds[0] + term2);
			    squaresigma_lower = (sigma_bounds[1] + term2) * (sigma_bounds[1] + term2);
			}
			
			
			bounds[1] = psi_upper/psi_upper_divisor - squaresigma_lower / sigma_lower_divisor ; 
			bounds[0] = psi_lower/psi_lower_divisor - squaresigma_upper / sigma_upper_divisor ; 
			
			//bounds[0] =  squaresigma_lower / sigma_lower_divisor ;
			//bounds[1] =  squaresigma_upper / sigma_upper_divisor ; 
			
			

		} catch (Exception e) {
			e.printStackTrace(System.out);
			// System.out.println(e.getMessage());
		}

		return bounds;

	}

	
	//select variance(value) from bigdata
	
}
