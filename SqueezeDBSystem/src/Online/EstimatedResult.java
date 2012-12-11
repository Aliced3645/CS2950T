package Online;

import java.util.Vector;

public class EstimatedResult {
	public Vector<Double> estimatedValue;
	public Vector<Double> lowerBound;
	public Vector<Double> upperBound;
	public Vector<String> aggregateName;
	
	public EstimatedResult(){
		estimatedValue = new Vector<Double>();
		lowerBound = new Vector<Double>();
		upperBound = new Vector<Double>();
		aggregateName = new Vector<String>();
	}
}
