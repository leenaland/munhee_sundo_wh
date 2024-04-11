package servlet.impl;

import java.util.List;
import java.util.Map;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

@Repository("ServletDAO")
public class ServletDAO extends EgovComAbstractDAO {

	@Autowired
	private SqlSessionTemplate session;

	public List<Map<String, Object>> sdList() {
		return selectList("servlet.sdList");
	}

	public List<Map<String, Object>> sggList(String sdparam) {
		return selectList("servlet.sggList", sdparam);
	}

	public void upfile(List<Map<String, Object>> list) {
		insert("servlet.upfile", list);
	}

	public List<Map<String, Object>> sdChartList() {
		return selectList("servlet.sdChartList");
	}

	public List<Map<String, Object>> sggChartList() {
		return selectList("servlet.sggChartList");
	}


}
