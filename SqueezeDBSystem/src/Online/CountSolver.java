package Online;

import java.util.HashMap;

import ilog.concert.IloException;
import ilog.concert.IloNumExpr;
import ilog.concert.IloNumVar;
import ilog.cplex.IloCplex;

public class CountSolver {
	

	public static CplexSolution solveCount(int target_value, double query_selectivity,
			HashMap<Integer, Float> selectivities, Float target_selectivity, 
			double eta, double epsilon, 
			boolean doMax) throws IloException{
		
		double lowerBound, upperBound;
		// apepared , calculate
		lowerBound = Math.max(target_selectivity * (1 - eta) / eta,
				-epsilon);
		upperBound = Math.min((1 - (query_selectivity - target_selectivity)
				/ eta)
				- target_selectivity, epsilon);

		IloCplex cplex = new IloCplex();
		IloNumVar[] epsilonV = cplex.numVarArray(1, lowerBound, upperBound);
		double[] coeffs = new double[1];
		coeffs[0] = 1;
		
		if(doMax == true){
			cplex.addMaximize(cplex.scalProd(epsilonV, coeffs));
		}
		else{
			cplex.addMinimize(cplex.scalProd(epsilonV, coeffs));

		}
		
		IloNumExpr[] ieExpr = new IloNumExpr[1];
		ieExpr[0] = cplex.prod(1.0, epsilonV[0]);
		IloNumExpr sumExpr = cplex.sum(ieExpr);
		cplex.addLe(sumExpr, Math.min(1 - query_selectivity, epsilon));
		cplex.addGe(sumExpr,
				Math.max(query_selectivity * (1 - eta) / eta, -epsilon));
		cplex.setOut(null);
		double[] solution_values;
		double obj_value = 0;
		CplexSolution solution = null;
		if (cplex.solve()) {
			solution_values = cplex.getValues(epsilonV);
			obj_value = cplex.getObjValue();

			solution = new CplexSolution(solution_values, obj_value);
			cplex.end();
		} else {
			cplex.end();
		}
		
		return solution;	
		
	}
}
