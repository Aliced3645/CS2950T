package Online;

public class Aggregator {
	public String name;
	public Aggregator() {
		this.name = "";
	}
	
	public void getAggregator(String originSQL) {
		String[] sql = originSQL.split(" ");
		if(sql[1].contains("sum")) {
			this.name = "sum";
		}
		else if(sql[1].contains("avg")) {
			this.name = "avg";
		}
	}
}
