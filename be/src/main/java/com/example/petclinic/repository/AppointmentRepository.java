package com.example.petclinic.repository;

import com.example.petclinic.entity.Appointment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.sql.Timestamp;
import java.util.List;

public interface AppointmentRepository extends JpaRepository<Appointment, Integer> {
    @Query(value = "Select appointment_time from appointments where doctor_id = :doctorId and status NOT IN (3,4) and appointment_time >= NOW()", nativeQuery = true)
    List<Timestamp> findTimeAppointmentByDoctorId(String doctorId);

    boolean existsAppointmentByAppointmentTimeAndDoctorId(Timestamp appointmentTime, String doctorId);

    @Query(value = "select * from appointments where user_id = :userId order by appointment_time desc ", nativeQuery = true)
    List<Appointment> findAllByUser(String userId);

    @Query(value = "select * from appointments where user_id = :userId and status = :status order by appointment_time desc", nativeQuery = true)
    List<Appointment> findAllByUserAndStatus(String userId, int status);

    @Query(value = "select  * from appointments where invoice_deposit_id = :id", nativeQuery = true)
    Appointment findAppointmentByInvoiceDeposit(int id);

    @Query(value = "SELECT * FROM appointments " +
            "WHERE doctor_id = :doctorId AND status IN (1,2, 10) AND appointment_time between :startDate AND :endDate", nativeQuery = true)
    List<Appointment> getAppointmentsToday( String doctorId, String startDate, String endDate);

    @Query(value = "select * from appointments where pet_id = :petId", nativeQuery = true)
    List<Appointment> getAppointmentByPetId(String petId);

    @Modifying
    @Query(value = "UPDATE appointments\n" +
            "    SET status = 4\n" +
            "    WHERE status = 0\n" +
            "      AND updated_at IS NOT NULL\n" +
            "      AND updated_at < (NOW() - INTERVAL 30 MINUTE)", nativeQuery = true)
    int updateExpiredAppointment();

    @Query(value = "SELECT * FROM appointments " +
            "WHERE status = 0 " +
            "AND updated_at IS NOT NULL " +
            "AND updated_at < (NOW() - INTERVAL 30 MINUTE)", nativeQuery = true)
    List<Appointment> findExpiredAppointments();

    @Query("""
    SELECT a FROM Appointment a 
    WHERE a.doctor IS NOT NULL 
       AND a.status IN (1,2,10) 
      AND a.appointmentTime >= :startOfWeek 
      AND a.appointmentTime < :endOfWeek
    ORDER BY a.doctor.fullname ASC, a.appointmentTime ASC
""")
    List<Appointment> findAllDoctorAppointmentsInWeek(
             Timestamp startOfWeek,
             Timestamp endOfWeek
    );
}
