USE RikkeiClinicDB_ss14;

DELIMITER //

CREATE PROCEDURE TransferBed(IN p_patient_id INT, IN p_new_bed_id INT)
BEGIN
    -- Thao tác 1: Giải phóng giường cũ
    UPDATE Beds SET patient_id = NULL WHERE patient_id = p_patient_id;

    -- Thao tác 2: Gắn giường mới
    UPDATE Beds SET patient_id = p_patient_id WHERE bed_id = p_new_bed_id;
END //

DELIMITER ;
/*
Trường hợp này vi phạm tính chất Atomicity (Tính nguyên tử) trong ACID.
Vì quá trình chuyển giường phải được thực hiện hoàn toàn cả 2 bước: giải phóng giường cũ và gán giường mới. 
Nhưng khi hệ thống gặp sự cố giữa chừng, 
chỉ bước đầu được thực hiện còn bước sau chưa chạy,làm dữ liệu bị không đồng bộ và bệnh nhân không còn nằm ở giường nào.*/
DROP PROCEDURE IF EXISTS TransferBed;

DELIMITER //
CREATE PROCEDURE TransferBed(IN p_patient_id INT, IN p_new_bed_id INT)
BEGIN
	-- Nếu có lỗi thì hoàn tác
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
	ROLLBACK;
    END;

    START TRANSACTION;

    -- Giải phóng giường cũ
    UPDATE Beds
    SET patient_id = NULL
    WHERE patient_id = p_patient_id;

    -- Gán giường mới
    UPDATE Beds
    SET patient_id = p_patient_id
    WHERE bed_id = p_new_bed_id;

    COMMIT;

END // 
DELIMITER ;

