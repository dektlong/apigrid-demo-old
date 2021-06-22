package io.storebackend.api.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

@Component
@Order(1)
public class TransactionFilter implements Filter {
    private final static Logger LOG = LoggerFactory.getLogger(TransactionFilter.class);

    @Override
    public void init(final FilterConfig filterConfig) throws ServletException {
        LOG.info("Initializing filter :{}", this);
    }

    @Override
    public void doFilter(final ServletRequest request, final ServletResponse response, final FilterChain chain) throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;

        // start tx for POST
        LOG.info(((HttpServletRequest) request).getMethod().equalsIgnoreCase("POST") ?
                    "TX started for a POST operation" :
                    "No TX started as it is not a POST operation");

        chain.doFilter(request, response);

        LOG.info(((HttpServletRequest) request).getMethod().equalsIgnoreCase("POST") ?
                    "TX commit for a POST operation" :
                    "No TX to commit");
    }

    @Override
    public void destroy() {
        LOG.warn("Destructing filter :{}", this);
    }
}
