package servlet.impl;

import java.util.List;
import java.util.Map;

import javax.annotation.Resource;

import org.springframework.stereotype.Service;

import egovframework.rte.fdl.cmmn.EgovAbstractServiceImpl;
import servlet.service.ServletService;

@Service("ServletService")
public class ServletImpl extends EgovAbstractServiceImpl implements ServletService {

	@Resource(name = "ServletDAO")
	private ServletDAO dao;

	@Override
	public List<Map<String, Object>> sdList() {
		return dao.sdList();
	}

	@Override
	public List<Map<String, Object>> sggList(String sdparam) {
		return dao.sggList(sdparam);
	}

	@Override
	public void upfile(List<Map<String, Object>> list) {
		dao.upfile(list);
	}

	@Override
	public List<Map<String, Object>> sdChartList() {
		return dao.sdChartList();
	}

	@Override
	public List<Map<String, Object>> sggChartList() {
		return dao.sggChartList();
	}	


}
