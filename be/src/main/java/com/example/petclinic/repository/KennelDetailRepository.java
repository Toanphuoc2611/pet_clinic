package com.example.petclinic.repository;

import com.example.petclinic.entity.KennelDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface KennelDetailRepository extends JpaRepository<KennelDetail, Integer> {
    @Query(value = "select * from kennel_details where user_id = :userId order by in_time", nativeQuery = true)
    List<KennelDetail> findAllByUser(String userId);

    @Query(value = "SELECT COUNT(*) from kennel_details where kennel_id = :kennel and status <= 2 ", nativeQuery = true)
    int findOverlappingBookings(int kennel);

    @Query(value = "select  * from kennel_details where invoice_deposit_id = :id", nativeQuery = true)
    KennelDetail findKennelByInvoiceDeposit(int id);

    @Query(value = "select * from kennel_details where doctor_id = :doctorId and status IN (1,2)", nativeQuery = true)
    List<KennelDetail> getKennelToday(String doctorId);

    @Query(value = "select * from kennel_details where pet_id = :petId", nativeQuery = true)
    List<KennelDetail> getKennelByPetId(String petId);

    @Modifying
    @Query(value = "UPDATE kennel_details\n" +
            "SET status = 4\n" +
            "WHERE in_time < CURRENT_TIMESTAMP\n" +
            "  AND status = 0", nativeQuery = true)
    int updateExpiredKennels();
}
