package org.xxg.backend.backend.filter;

import org.springframework.stereotype.Component;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.concurrent.atomic.AtomicLong;

@Component
public class RequestMonitorFilter implements Filter {

    private final AtomicLong totalRequests = new AtomicLong(0);
    private final AtomicLong totalErrors = new AtomicLong(0);
    private final AtomicLong totalTime = new AtomicLong(0);

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        String requestURI = httpRequest.getRequestURI();

        // 排除静态资源和OPTIONS请求
        if (requestURI.startsWith("/uploads/") || "OPTIONS".equalsIgnoreCase(httpRequest.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        long startTime = System.currentTimeMillis();
        
        try {
            totalRequests.incrementAndGet();
            chain.doFilter(request, response);
        } finally {
            long duration = System.currentTimeMillis() - startTime;
            totalTime.addAndGet(duration);
            
            if (response instanceof HttpServletResponse) {
                int status = ((HttpServletResponse) response).getStatus();
                if (status >= 400) {
                    totalErrors.incrementAndGet();
                }
            }
        }
    }

    public long getTotalRequests() {
        return totalRequests.get();
    }

    public long getTotalErrors() {
        return totalErrors.get();
    }

    public double getAvgResponseTime() {
        long requests = totalRequests.get();
        if (requests == 0) return 0;
        return (double) totalTime.get() / requests;
    }
}
