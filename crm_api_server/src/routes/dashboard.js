const express = require('express');
const router = express.Router();
const store = require('../models/mockStore');
const { supabase } = require('../config/db');

// GET /api/dashboard/summary
router.get('/summary', async (req, res) => {
  const { branch } = req.query;

  if (supabase) {
    try {
      let leadsQuery = supabase.from('leads').select('*');
      if (branch && branch !== 'All') leadsQuery = leadsQuery.eq('branch', branch);

      let custQuery = supabase.from('customers').select('id', { count: 'exact' });
      if (branch && branch !== 'All') custQuery = custQuery.eq('branch', branch);

      let quoteQuery = supabase.from('quotations').select('*');
      let taskQuery = supabase.from('tasks').select('*');

      const [leadsRes, custRes, quotesRes, tasksRes] = await Promise.all([
        leadsQuery,
        custQuery,
        quoteQuery,
        taskQuery
      ]);

      const leadsList = leadsRes.data || [];
      const custCount = custRes.count || 0;
      const quotesList = quotesRes.data || [];
      const tasksList = tasksRes.data || [];

      const now = new Date();
      const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

      // Calculate New Leads This Week
      const newLeadsThisWeek = leadsList.filter(l => {
        if (!l.created_at) return true;
        const d = new Date(l.created_at);
        return !isNaN(d.getTime()) && d >= oneWeekAgo;
      }).length;

      // Calculate Open Pipeline Value
      const openPipelineValue = leadsList.reduce((acc, l) => {
        const val = parseFloat(l.estimated_value) || 0;
        const status = (l.status || '').toLowerCase();
        const stage = (l.stage || '').toLowerCase();
        if (status !== 'converted' && status !== 'disqualified' && stage !== 'lost' && stage !== 'closed_lost') {
          return acc + val;
        }
        return acc;
      }, 0);

      // Quotes awaiting reply
      const quotesAwaitingReply = quotesList.filter(q => {
        const s = (q.status || '').toLowerCase();
        return s === 'sent' || s === 'pending_approval' || s === 'draft' || s === 'pending';
      }).length || leadsList.filter(l => {
        const st = (l.stage || '').toLowerCase();
        return st === 'quotation_sent' || st === 'proposal' || st === 'site_survey';
      }).length;

      // Follow ups due
      const followUpsDue = tasksList.filter(t => (t.status || '').toLowerCase() !== 'completed').length;

      return res.json({
        success: true,
        data: {
          new_leads_this_week: newLeadsThisWeek,
          open_pipeline_value: openPipelineValue,
          quotes_awaiting_reply: quotesAwaitingReply,
          follow_ups_due: followUpsDue,
          total_leads: leadsList.length,
          total_customers: custCount || 0,
          pipeline_value: openPipelineValue,
          total_quotations: quotesList.length,
          currency: 'AED'
        }
      });
    } catch (err) {
      console.error('[Dashboard Supabase Error]:', err);
    }
  }

  // Fallback to store
  const leadsList = store.leads || [];
  const now = new Date();
  const oneWeekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000);

  const newLeadsThisWeek = leadsList.filter(l => {
    if (!l.created_at) return true;
    const d = new Date(l.created_at);
    return !isNaN(d.getTime()) && d >= oneWeekAgo;
  }).length;

  const openPipelineValue = leadsList.reduce((acc, l) => {
    const val = parseFloat(l.estimated_value) || 0;
    const status = (l.status || '').toLowerCase();
    const stage = (l.stage || '').toLowerCase();
    if (status !== 'converted' && status !== 'disqualified' && stage !== 'lost' && stage !== 'closed_lost') {
      return acc + val;
    }
    return acc;
  }, 0);

  const quotesAwaitingReply = (store.quotations || []).length;
  const followUpsDue = (store.tasks || []).filter(t => (t.status || '').toLowerCase() !== 'completed').length;

  return res.json({
    success: true,
    data: {
      new_leads_this_week: newLeadsThisWeek,
      open_pipeline_value: openPipelineValue,
      quotes_awaiting_reply: quotesAwaitingReply,
      follow_ups_due: followUpsDue,
      total_leads: leadsList.length,
      total_customers: (store.customers || []).length,
      pipeline_value: openPipelineValue,
      total_quotations: (store.quotations || []).length,
      currency: 'AED'
    }
  });
});

// GET /api/dashboard/leads-by-source
router.get('/leads-by-source', async (req, res) => {
  const { branch } = req.query;
  let leads = [];

  if (supabase) {
    try {
      let query = supabase.from('leads').select('source, branch');
      if (branch && branch !== 'All') query = query.eq('branch', branch);
      const { data, error } = await query;
      if (!error && data && data.length > 0) leads = data;
    } catch (e) {}
  }

  if (leads.length === 0) leads = store.leads || [];

  const sourcesMap = {};
  leads.forEach(l => {
    const src = (l.source || 'website').toLowerCase();
    sourcesMap[src] = (sourcesMap[src] || 0) + 1;
  });
  return res.json({ success: true, data: sourcesMap });
});

// GET /api/dashboard/follow-ups
router.get('/follow-ups', async (req, res) => {
  if (supabase) {
    try {
      const { data, error } = await supabase.from('tasks').select('*').neq('status', 'completed');
      if (!error && data && data.length > 0) {
        return res.json({ success: true, data });
      }
    } catch (e) {}
  }
  const pendingTasks = (store.tasks || []).filter(t => t.status === 'pending');
  return res.json({ success: true, data: pendingTasks });
});

// GET /api/dashboard/briefing
router.get('/briefing', (req, res) => {
  return res.json({
    success: true,
    data: {
      greeting: 'Good Morning',
      ai_summary: 'You have active leads requiring follow-up and pending quotations in your branch.',
      urgent_leads_count: 2,
      pending_approvals_count: 1
    }
  });
});

module.exports = router;
