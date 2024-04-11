package servlet.service;

import java.util.List;
import java.util.Map;

public interface ServletService {

	List<Map<String, Object>> sdList();

	List<Map<String, Object>> sggList(String sdparam);

	void upfile(List<Map<String, Object>> list);

	List<Map<String, Object>> sdChartList();

	List<Map<String, Object>> sggChartList();
}
