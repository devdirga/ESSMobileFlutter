import 'package:ess_mobile/views/attendance/attendance_screen.dart';
import 'package:ess_mobile/views/payroll/simulasi_peminjaman_request_screen.dart';
import 'package:ess_mobile/views/payroll/simulasi_peminjaman_screen.dart';
import 'package:flutter/material.dart';
import 'package:ess_mobile/views/auth/login_screen.dart';
import 'package:ess_mobile/views/auth/register_screen.dart';
import 'package:ess_mobile/views/auth/forgot_password_screen.dart';
import 'package:ess_mobile/views/auth/create_password_screen.dart';
import 'package:ess_mobile/views/auth/change_password_screen.dart';
import 'package:ess_mobile/views/auth/verification_code_screen.dart';
import 'package:ess_mobile/views/appbrowser.dart';
import 'package:ess_mobile/views/downloader.dart';
import 'package:ess_mobile/views/dashboard/dashboard_screen.dart';
import 'package:ess_mobile/views/complaint/complaint_screen.dart';
import 'package:ess_mobile/views/complaint/complaint_entry_screen.dart';
import 'package:ess_mobile/views/complaint/resolution_screen.dart';
import 'package:ess_mobile/views/complaint/resolution_entry_screen.dart';
import 'package:ess_mobile/views/complaint/ticket_category_screen.dart';
import 'package:ess_mobile/views/employee/document_request_screen.dart';
import 'package:ess_mobile/views/employee/document_request_entry_screen.dart';
import 'package:ess_mobile/views/employee/profile_screen.dart';
import 'package:ess_mobile/views/employee/resume_screen.dart';
import 'package:ess_mobile/views/employee/family_screen.dart';
import 'package:ess_mobile/views/employee/family_entry_screen.dart';
import 'package:ess_mobile/views/employee/employment_screen.dart';
import 'package:ess_mobile/views/employee/certificate_screen.dart';
import 'package:ess_mobile/views/employee/certificate_entry_screen.dart';
import 'package:ess_mobile/views/employee/warning_letter_screen.dart';
import 'package:ess_mobile/views/employee/medical_record_screen.dart';
import 'package:ess_mobile/views/employee/document_screen.dart';
import 'package:ess_mobile/views/time_management/time_attendance_screen.dart';
import 'package:ess_mobile/views/time_management/subordinate_attendance_screen.dart';
import 'package:ess_mobile/views/time_management/agenda_screen.dart';
import 'package:ess_mobile/views/time_management/agenda_detail_screen.dart';
import 'package:ess_mobile/views/time_management/recommendation_absence_screen.dart';
import 'package:ess_mobile/views/payroll/payslip_screen.dart';
import 'package:ess_mobile/views/leave/leave_screen.dart';
import 'package:ess_mobile/views/leave/request_screen.dart';
import 'package:ess_mobile/views/travel/travel_screen.dart';
import 'package:ess_mobile/views/travel/travel_request_screen.dart';
import 'package:ess_mobile/views/training/training_screen.dart';
import 'package:ess_mobile/views/training/join_screen.dart';
import 'package:ess_mobile/views/recruitment/recruitment_screen.dart';
import 'package:ess_mobile/views/sleep_monitor/sleep_screen.dart';
import 'package:ess_mobile/views/sleep_monitor/sleep_entry_screen.dart';
import 'package:ess_mobile/views/chat/chat_screen.dart';
import 'package:ess_mobile/views/chat/contact_screen.dart';
import 'package:ess_mobile/views/task/task_screen.dart';
import 'package:ess_mobile/views/task/request_screen.dart';
import 'package:ess_mobile/views/task/notification_screen.dart';
import 'package:ess_mobile/views/task_detail/complaint_screen.dart';
import 'package:ess_mobile/views/task_detail/resume_screen.dart';
import 'package:ess_mobile/views/task_detail/family_screen.dart';
import 'package:ess_mobile/views/task_detail/certificate_screen.dart';
import 'package:ess_mobile/views/task_detail/leave_screen.dart';
import 'package:ess_mobile/views/task_detail/absence_screen.dart';
import 'package:ess_mobile/views/task_detail/sppd_screen.dart';
import 'package:ess_mobile/views/survey/survey_screen.dart';

class Routes {
  Routes._();

  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgotPassword';
  static const String createPassword = '/createPassword';
  static const String changePassword = '/changePassword';
  static const String verificationCode = '/verificationCode';
  static const String appbrowser = '/appbrowser';
  static const String downloader = '/downloader';
  static const String dashboard = '/dashboard';
  static const String profile = '/profile';
  static const String documentRequest = '/documentRequest';
  static const String documentRequestEntry = '/documentRequestEntry';
  static const String resume = '/resume';
  static const String family = '/family';
  static const String familyEntry = '/familyEntry';
  static const String employment = '/employment';
  static const String certificate = '/certificate';
  static const String certificateEntry = '/certificateEntry';
  static const String warningLetter = '/warningLetter';
  static const String medicalRecord = '/medicalRecord';
  static const String document = '/document';
  static const String timeAttendance = '/timeAttendance';
  static const String subordinateAttendance = '/subordinateAttendance';
  static const String agenda = '/agenda';
  static const String agendaDetail = '/agendaDetail';
  static const String recommendationAbsence = '/recommendationAbsence';
  static const String payslip = '/payslip';
  static const String leave = '/leave';
  static const String leaveRequest = '/leaveRequest';
  static const String travel = '/travel';
  static const String travelRequest = '/travelRequest';
  static const String training = '/training';
  static const String trainingJoin = '/trainingJoin';
  static const String recruitment = '/recruitment';
  static const String sleepMonitor = '/sleepMonitor';
  static const String sleepMonitorEntry = '/sleepMonitorEntry';
  static const String notification = '/notification';
  static const String chat = '/chat';
  static const String chatContact = '/chatContact';
  static const String task = '/task';
  static const String taskRequest = '/taskRequest';
  static const String complaintDetail = '/complaintDetail';
  static const String resumeDetail = '/resumeDetail';
  static const String familyDetail = '/familyDetail';
  static const String certificateDetail = '/certificateDetail';
  static const String leaveDetail = '/leaveDetail';
  static const String absenceDetail = '/absenceDetail';
  static const String sppdDetail = '/sppdDetail';
  static const String simLoan = '/simloan';
  static const String requestLoan = '/requestloan';
  static const String complaints = '/complaints';
  static const String complaintEntry = '/complaintEntry';
  static const String resolutions = '/resolutions';
  static const String resolutionEntry = '/resolutionEntry';
  static const String ticketCategories = '/ticketCategories';
  static const String survey = '/survey';
  static const String attendance = '/attendance';

  static final routes = <String, WidgetBuilder>{
    login: (BuildContext context) => LoginScreen(),
    register: (BuildContext context) => RegisterScreen(),
    forgotPassword: (BuildContext context) => ForgotPasswordScreen(),
    createPassword: (BuildContext context) => CreatePasswordScreen(),
    changePassword: (BuildContext context) => ChangePasswordScreen(),
    verificationCode: (BuildContext context) => VerificationCodeScreen(),
    appbrowser: (BuildContext context) => Appbrowser(),
    downloader: (BuildContext context) => Downloader(),
    dashboard: (BuildContext context) => DashboardScreen(),
    profile: (BuildContext context) => ProfileScreen(),
    documentRequest: (BuildContext context) => DocumentRequestScreen(),
    documentRequestEntry: (BuildContext context) =>
        DocumentRequestEntryScreen(),
    resume: (BuildContext context) => ResumeScreen(),
    family: (BuildContext context) => FamilyScreen(),
    familyEntry: (BuildContext context) => FamilyEntryScreen(),
    employment: (BuildContext context) => EmploymentScreen(),
    certificate: (BuildContext context) => CertificateScreen(),
    certificateEntry: (BuildContext context) => CertificateEntryScreen(),
    warningLetter: (BuildContext context) => WarningLetterScreen(),
    medicalRecord: (BuildContext context) => MedicalRecordScreen(),
    document: (BuildContext context) => DocumentScreen(),
    timeAttendance: (BuildContext context) => TimeAttendanceScreen(),
    subordinateAttendance: (BuildContext context) =>
        SubordinateAttendanceScreen(),
    agenda: (BuildContext context) => AgendaScreen(),
    agendaDetail: (BuildContext context) => AgendaDetailScreen(),
    recommendationAbsence: (BuildContext context) =>
        RecommendationAbsenceScreen(),
    payslip: (BuildContext context) => PayslipScreen(),
    leave: (BuildContext context) => LeaveScreen(),
    leaveRequest: (BuildContext context) => LeaveRequestScreen(),
    travel: (BuildContext context) => TravelScreen(),
    travelRequest: (BuildContext context) => TravelRequestScreen(),
    training: (BuildContext context) => TrainingScreen(),
    trainingJoin: (BuildContext context) => TrainingJoinScreen(),
    recruitment: (BuildContext context) => RecruitmentScreen(),
    sleepMonitor: (BuildContext context) => SleepScreen(),
    sleepMonitorEntry: (BuildContext context) => SleepEntryScreen(),
    notification: (BuildContext context) => NotificationScreen(),
    chat: (BuildContext context) => ChatScreen(),
    chatContact: (BuildContext context) => ContactScreen(),
    task: (BuildContext context) => TaskScreen(),
    taskRequest: (BuildContext context) => TaskRequestScreen(),
    complaintDetail: (BuildContext context) => ComplaintDetail(),
    resumeDetail: (BuildContext context) => ResumeDetail(),
    familyDetail: (BuildContext context) => FamilyDetail(),
    certificateDetail: (BuildContext context) => CertificateDetail(),
    leaveDetail: (BuildContext context) => LeaveDetail(),
    absenceDetail: (BuildContext context) => AbsenceDetail(),
    sppdDetail: (BuildContext context) => SppdDetail(),
    simLoan: (BuildContext context) => SimLoanScreen(),
    requestLoan: (BuildContext context) => LoanRequestScreen(),
    complaints: (BuildContext context) => ComplaintScreen(),
    complaintEntry: (BuildContext context) => ComplaintEntryScreen(),
    resolutions: (BuildContext context) => ResolutionScreen(),
    resolutionEntry: (BuildContext context) => ResolutionEntryScreen(),
    ticketCategories: (BuildContext context) => TicketCategoriesScreen(),
    survey: (BuildContext context) => SurveyScreen(),
    attendance: (BuildContext context) => AttendanceScreen(selectedPage: 0,),
  };
}
